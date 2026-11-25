#!/bin/sh
set -eu

errors=$(mktemp)
trap 'rm -f "$errors"' EXIT

findings() {
  group=$1 fields=$2
  shift 2
  gh api --method GET --paginate -H 'X-GitHub-Api-Version: 2026-03-10' "repos/{owner}/{repo}/$group" -f state=open -F per_page=100 "$@" \
    --jq '.[] | ["#\(.number)", '"$fields"'] | map(values) | join(" ")'
}

list() {
  case $1 in
    code-scanning/alerts) findings "$1" '.rule.security_severity_level // .rule.severity, .rule.id, "\(.most_recent_instance.location.path):\(.most_recent_instance.location.start_line)", .html_url' ;;
    # The default list leaves out generic secrets such as passwords, which must be asked for by type.
    secret-scanning/alerts)
      set -- "$1" '.secret_type_display_name, .first_location_detected.path, .html_url' -F hide_secret=true
      findings "$@" && findings "$@" -f secret_type=ec_private_key,generic_private_key,http_basic_authentication_header,http_bearer_authentication_header,mongodb_connection_string,mysql_connection_url,openssh_private_key,pgp_private_key,postgres_connection_string,rsa_private_key,password
      ;;
    dependabot/alerts) findings "$1" '.security_advisory.severity, .security_advisory.ghsa_id, "\(.dependency.package.ecosystem):\(.dependency.package.name)", .dependency.manifest_path, .html_url' ;;
    code-quality/findings) findings "$1" '.rule.severity, .rule.id, "\(.location.path):\(.location.start_line)", .url' ;;
  esac
}

listed=
for group in code-scanning/alerts secret-scanning/alerts dependabot/alerts code-quality/findings; do
  lines=$(list "$group" 2>"$errors") || continue
  listed=1
  echo "## $group: $(printf '%s' "$lines" | grep -c . || true)"
  [ -z "$lines" ] || printf '%s\n' "$lines"
done
[ -n "$listed" ] || {
  echo "list-github-findings.sh: no finding could be read: $(head -n 1 "$errors")" >&2
  exit 1
}
