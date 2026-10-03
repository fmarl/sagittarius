#!/usr/bin/env bash
# Open a pull request for each update of a package in etc/updates.scm that
# builds, unless its branch exists.  Fail if an update does not build.

set -euo pipefail

refresh=$(guix refresh -L modules -m etc/updates.scm 2>&1 | tee /dev/stderr)
failed=()

while read -r name old new; do
    branch="update/$name-$new"

    if git ls-remote --exit-code --heads origin "$branch" >/dev/null; then
        continue
    fi

    guix refresh -L modules -u "$name@$old"

    if ! git diff --quiet && guix build -L modules "$name@$new"; then
        git switch --quiet --create "$branch"
        git commit --quiet --all --message "$name: Update to $new"
        git push --quiet --set-upstream origin "$branch"
        gh pr create --fill
        git switch --quiet -
    else
        failed+=("$name@$new")
        git reset --quiet --hard
    fi
done < <(sed -nE 's/^.*: ([^ ]+) would be upgraded from ([^ ]+) to ([^ ]+)$/\1 \2 \3/p' <<<"$refresh")

if ((${#failed[@]})); then
    printf 'Updating failed: %s\n' "${failed[@]}" >&2
    exit 1
fi
