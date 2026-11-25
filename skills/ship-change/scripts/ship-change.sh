#!/bin/sh
set -eu

usage='usage: ship-change.sh state | check <stage or initials>... | branch [<name>] | commit [--main] <title> | pr <title> < body | review | resolve <thread-id> <ADDRESSED|WONT_FIX> <reply> | merge [<title>]'
die() {
  printf 'ship-change.sh: %s\n' "$*" >&2
  exit 1
}

stages='branch commit pr review merge'
nl='
'

default_branch() {
  ref=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD) || {
    git remote set-head origin --auto >/dev/null
    ref=$(git symbolic-ref --short refs/remotes/origin/HEAD)
  }
  echo "${ref#origin/}"
}

current_branch() {
  branch=$(git branch --show-current)
  [ -n "$branch" ] || die 'HEAD is detached'
  echo "$branch"
}

# Sets number, state and url to the branch's newest pull request, each empty without one.
pull_request() {
  read -r number state url <<EOF
$(gh pr list --head "$1" --state all --limit 1 --json number,state,url --jq '.[] | "\(.number) \(.state) \(.url)"')
EOF
}

open_pull_request() {
  branch=$(current_branch) && pull_request "$branch" && [ "$state" = OPEN ]
}

title_error() {
  case $1 in *"$nl"*)
    echo 'a title takes one line'
    return
    ;;
  esac
  length=$(($(printf '%s' "$1" | wc -m)))
  if [ "$length" -gt 72 ]; then
    echo "the title has $length characters, at most 72 are allowed"
  elif ! printf '%s\n' "$1" | grep -Eq '^(build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test)(\([^)]+\))?!?: [^ ]'; then
    echo 'the title is not a Conventional Commits title'
  fi
}

check_title() {
  error=$(title_error "$1")
  [ -z "$error" ] || die "$error: $1"
}

outstanding() {
  if [ -n "$(git status --porcelain)" ]; then
    echo 'uncommitted changes'
  elif ! git rev-parse --verify --quiet '@{upstream}' >/dev/null; then
    echo 'unpushed branch'
  elif [ "$(git rev-list --count '@{upstream}..HEAD')" -gt 0 ]; then
    echo 'unpushed commits'
  fi
}

# Prints each check as "<bucket> <name> <link>".
checks() {
  gh pr checks "$1" --json bucket,name,link --jq '.[] | "\(.bucket) \(.name) \(.link)"' 2>/dev/null || true
}

graph() {
  gh api graphql -F owner='{owner}' -F repo='{repo}' -F number="$1" --jq ".data.repository.pullRequest | $2" -f query='
    query($owner: String!, $repo: String!, $number: Int!) {
      repository(owner: $owner, name: $repo) {
        pullRequest(number: $number) {
          reviewRequests(first: 20) { nodes { requestedReviewer { ... on Bot { login } } } }
          reviewThreads(first: 100) { nodes { id isResolved path line comments(first: 1) { nodes { isCopilotCodeReview body } } } }
        }
      }
    }'
}

copilot_threads='[.reviewThreads.nodes[] | select((.isResolved | not) and .comments.nodes[0].isCopilotCodeReview)]'

run_from() {
  run='' started=''
  for stage in $stages; do
    [ "$stage" != "$1" ] || started=1
    [ -z "$started" ] || run="$run $stage"
    [ "$stage" != "$2" ] || break
  done
  echo "${run# }"
}

# Prints the stages its arguments name, one per line, taking each argument as a stage or else as a string of stage initials such as `prm`.
named_stages() {
  for arg; do
    case " $stages " in *" $arg "*)
      echo "$arg"
      continue
      ;;
    esac
    rest=$arg
    while [ -n "$rest" ]; do
      initial=${rest%"${rest#?}"}
      rest=${rest#?}
      for stage in $stages; do
        case $stage in "$initial"*)
          echo "$stage"
          continue 2
          ;;
        esac
      done
      die "unknown stage '$initial' in '$arg', the stages are: $stages, or their initials"
    done
  done
}

case ${1-} in
  state)
    git fetch --quiet origin
    default=$(default_branch)
    branch=$(current_branch)
    echo "default: $default"
    echo "branch: $branch"
    echo "behind: $(git rev-list --count "HEAD..origin/$default")"
    echo "ahead: $(git rev-list --count "origin/$default..HEAD")"
    echo "uncommitted: $(git status --porcelain | wc -l | tr -d ' ')"
    if git rev-parse --verify --quiet '@{upstream}' >/dev/null; then
      echo "unpushed: $(git rev-list --count '@{upstream}..HEAD')"
    else
      echo 'unpushed: no upstream'
    fi
    [ "$branch" != "$default" ] || exit 0
    pull_request "$branch"
    echo "pull request: ${number:-none} $state $url"
    [ "$state" = OPEN ] || exit 0
    echo "checks: $(checks "$number" | cut -d' ' -f1 | sort | uniq -c | awk '{printf "%s%s %s", sep, $1, $2; sep=", "} END {if (!NR) printf "none"}')"
    echo "open Copilot threads: $(graph "$number" "$copilot_threads | length")"
    ;;
  check)
    shift
    [ $# -gt 0 ] || die "$usage"
    run=$(named_stages "$@")
    set -- $run
    first=$1 end=${run##*"$nl"}
    [ "$*" = "$(run_from "$first" "$end")" ] || die "the stages run in the order $stages, without gaps"
    case $first in branch | commit)
      echo "$*"
      exit 0
      ;;
    esac
    git fetch --quiet origin
    default=$(default_branch)
    [ "$(current_branch)" != "$default" ] || die "on $default: run \`$(run_from commit "$end")\`"
    reason=$(outstanding)
    [ -z "$reason" ] || die "$reason: run \`$(run_from commit "$end")\`"
    if [ "$first" = pr ]; then
      [ "$(git rev-list --count "origin/$default..HEAD")" -gt 0 ] || die "no commits ahead of $default"
    else
      open_pull_request || die "no open pull request: run \`$(run_from pr "$end")\`"
    fi
    echo "$*"
    ;;
  branch)
    shift
    git fetch --quiet origin
    default=$(default_branch)
    branch=$(current_branch)
    if [ "$branch" = "$default" ]; then
      [ $# -eq 1 ] || die "on $default: pass the new branch's name"
      git switch --quiet --create "$1" --no-track "origin/$default"
    else
      [ $# -eq 0 ] || die "already on $branch, which takes no name"
      pull_request "$branch"
      case $state in MERGED | CLOSED) die "pull request $number of $branch is $state: this branch is not meant for new changes" ;; esac
      if [ "$(git rev-list --count "HEAD..origin/$default")" -gt 0 ]; then
        git rebase --quiet --autostash "origin/$default" || {
          git rebase --abort 2>/dev/null || true
          die "rebasing $branch onto origin/$default conflicts; nothing changed"
        }
      fi
    fi
    current_branch
    ;;
  commit)
    shift
    main=
    [ "${1-}" != --main ] || {
      main=1
      shift
    }
    [ $# -eq 1 ] || die "$usage"
    check_title "$1"
    default=$(default_branch)
    [ "$(current_branch)" != "$default" ] || [ -n "$main" ] || die "on $default: run branch first, or pass --main where the repository says to commit to $default"
    if [ -n "$(git status --porcelain)" ]; then
      git add --all
      git commit --quiet --message "$1"
    fi
    if [ -n "$main" ]; then
      git push --quiet origin HEAD
    else
      git push --quiet --force-with-lease --set-upstream origin HEAD
    fi
    git rev-parse --short HEAD
    ;;
  pr)
    shift
    [ $# -eq 1 ] || die "$usage"
    check_title "$1"
    body=$(cat)
    bullets=$(printf '%s\n' "$body" | grep -c '^- ' || true)
    others=$(printf '%s\n' "$body" | grep -cv -e '^- ' -e '^$' || true)
    [ "$others" -eq 0 ] && [ "$bullets" -ge 1 ] && [ "$bullets" -le 10 ] || die 'the body takes one to ten lines starting with "- "'
    if printf '%s\n' "$body" | grep -qi -e 'co-authored-by' -e 'generated with'; then
      die 'the body carries attribution'
    fi
    if open_pull_request; then
      echo "$url"
    else
      printf '%s\n' "$body" | gh pr create --base "$(default_branch)" --title "$1" --body-file -
    fi
    ;;
  review)
    shift
    [ $# -eq 0 ] || die "$usage"
    open_pull_request || die 'no open pull request for this branch'
    deadline=$(($(date +%s) + 90))
    while :; do
      pending=
      [ $(($(date +%s) - $(git log -1 --format=%ct HEAD))) -ge 60 ] || pending='the head commit is under a minute old'
      ! checks "$number" | grep -q '^pending ' || pending='checks are running'
      [ "$(graph "$number" '[.reviewRequests.nodes[].requestedReviewer.login] | any(. == "copilot-pull-request-reviewer")')" = false ] || pending='Copilot is reviewing'
      [ -n "$pending" ] || break
      [ "$(date +%s)" -lt "$deadline" ] || {
        echo "pending: $pending"
        exit 8
      }
      sleep 10
    done
    failing=$(checks "$number" | grep -e '^fail ' -e '^cancel ' || true)
    threads=$(graph "$number" "$copilot_threads | .[] | \"thread \\(.id) \\(.path):\\(.line // \"file\")\\n\\(.comments.nodes[0].body)\\n\"")
    if [ -z "$failing$threads" ]; then
      echo clean
    else
      [ -z "$failing" ] || printf '%s\n' "$failing" | sed 's/^[a-z]* /failing check: /'
      [ -z "$threads" ] || printf '%s\n' "$threads"
    fi
    ;;
  resolve)
    shift
    [ $# -eq 3 ] || die "$usage"
    case $2 in ADDRESSED | WONT_FIX) ;; *) die "$usage" ;; esac
    gh api graphql -f thread="$1" -f body="$3" --silent -f query='
      mutation($thread: ID!, $body: String!) {
        addPullRequestReviewThreadReply(input: { pullRequestReviewThreadId: $thread, body: $body }) { comment { id } }
      }'
    gh api graphql -f thread="$1" -f reason="$2" --silent -f query='
      mutation($thread: ID!, $reason: PullRequestReviewThreadResolutionReason) {
        resolveReviewThread(input: { threadId: $thread, resolutionReason: $reason }) { thread { id } }
      }'
    ;;
  merge)
    shift
    [ $# -le 1 ] || die "$usage"
    open_pull_request || die 'no open pull request for this branch'
    if [ $# -eq 1 ]; then
      check_title "$1"
      gh pr edit "$number" --title "$1" >/dev/null
    fi
    title=$(gh pr view "$number" --json title --jq .title)
    error=$(title_error "$title")
    [ -z "$error" ] || die "$error: pass a rewritten title"
    ! checks "$number" | grep -qv -e '^pass ' -e '^skipping ' || die 'a check fails or is pending: run `review merge`'
    [ "$(gh pr view "$number" --json mergeable --jq .mergeable)" != CONFLICTING ] || die "pull request $number has conflicts"
    body=$(gh pr view "$number" --json body --jq .body)
    head=$(gh pr view "$number" --json headRefOid --jq .headRefOid)
    set -- "$number" --squash --subject "$title (#$number)" --body "$body" --match-head-commit "$head" --delete-branch
    gh pr merge "$@" || gh pr merge "$@" --admin
    git switch --quiet "$(default_branch)"
    git pull --quiet --ff-only
    ;;
  *) die "$usage" ;;
esac
