#!/bin/sh
set -eu
export LC_ALL=C

usage='usage: context.sh themes | entries [<theme>...] | show <id>... | theme <name> [--title <t>] [--summary <s>] [--rename <new>] | add <theme> <heading> <fields> < body | set <id> [--heading <h>] <fields> [--body < body] | move <id> <theme>'
die() {
  printf 'context.sh: %s\n' "$*" >&2
  exit 1
}

fields='type status evidence source verification revisit-when see superseded-by'
case ${1-} in
  themes | entries | show) count='' options='' ;;
  theme) count=1 options='title summary rename' ;;
  add) count=2 options=$fields ;;
  set) count=1 options="heading body $fields" ;;
  move) count=2 options='' ;;
  *) die "$usage" ;;
esac
CMD=$1
shift

nl='
'
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
ARGS='' OPTS='' BODY='' NEWID='' n=0
while [ $# -gt 0 ]; do
  case $1 in
    --*) break ;;
    *"$nl"*) die "an argument takes one line" ;;
  esac
  ARGS=$ARGS$1$nl n=$((n + 1))
  shift
done
[ -z "$count" ] || [ "$n" -eq "$count" ] || die "$usage"
while [ $# -gt 0 ]; do
  option=${1#--}
  case " $options " in
    *" $option "*) ;;
    *) die "$CMD takes no option $1" ;;
  esac
  if [ "$option" = body ]; then
    BODY=$tmp/body
    shift
    continue
  fi
  [ $# -ge 2 ] || die "$1 needs a value"
  case $2 in *"$nl"*) die "$1 takes one line" ;; esac
  OPTS=$OPTS$option' '$2$nl
  shift 2
done

if [ "$CMD" = add ]; then
  BODY=$tmp/body
  NEWID=$( (uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid 2>/dev/null || true) | tr A-F a-f)
fi
if [ -n "$BODY" ]; then cat > "$BODY"; fi

dir="$(git rev-parse --show-toplevel 2>/dev/null || pwd)/docs/context"
if [ "$CMD" = theme ]; then mkdir -p "$dir"; fi
set -- /dev/null
for file in "$dir"/*.md; do
  if [ -f "$file" ]; then set -- "$@" "$file"; fi
done
CMD=$CMD ARGS=$ARGS OPTS=$OPTS BODY=$BODY NEWID=$NEWID DIR=$dir TODAY=$(date +%F) RMLIST=$tmp/rm \
  awk -f "$(dirname "$0")/context.awk" "$@"
if [ -f "$tmp/rm" ]; then
  while IFS= read -r file; do rm "$file"; done < "$tmp/rm"
fi
