#!/usr/bin/env bash
set -euo pipefail

title='Package updates'

refresh=$(guix refresh -L modules -m etc/updates.scm 2>&1 | tee /dev/stderr)
report=()

while read -r name old new; do
    if guix refresh -L modules -u "$name@$old" && guix build -L modules "$name@$new"; then
        status='builds'
    else
        status='**fails to build**'
    fi
    report+=("- \`$name\` $old → $new: $status")
    git checkout --quiet -- .
done < <(sed -nE 's/^.*: ([^ ]+) would be upgraded from ([^ ]+) to ([^ ]+)$/\1 \2 \3/p' <<<"$refresh")

issue=$(gh issue list --state open --search "in:title \"$title\"" \
           --json number,title --jq ".[] | select(.title == \"$title\") | .number" |
            head -n 1)

if ((${#report[@]} == 0)); then
    if [[ -n $issue ]]; then
        gh issue close "$issue" --comment 'All packages are up to date.'
    fi
    exit 0
fi

body=$(printf '%s\n' "${report[@]}"
       printf '\nUpdate locally with `etc/update-packages PACKAGE...`.\n')

if [[ -n $issue ]]; then
    gh issue edit "$issue" --body "$body"
else
    gh issue create --title "$title" --body "$body"
fi
