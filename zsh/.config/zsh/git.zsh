# Git helpers.

# Delete local branches whose upstream remote branch no longer exists.
# Usage: git-prune-gone [-f]   (-f skips the confirmation prompt)
git-prune-gone() {
  git rev-parse --git-dir >/dev/null 2>&1 || { echo "Not a git repository"; return 1; }

  git fetch --all --prune --quiet || return 1

  # Skip the current branch and branches checked out in other worktrees.
  local -a gone
  gone=(${(f)"$(git for-each-ref refs/heads \
    --format='%(refname:short)|%(upstream:track)|%(HEAD)|%(worktreepath)' \
    | awk -F'|' '$2 == "[gone]" && $3 != "*" && $4 == "" { print $1 }')"})

  if (( ${#gone} == 0 )); then
    echo "No branches with a gone upstream."
    return 0
  fi

  echo "Branches with a gone upstream:"
  printf '  %s\n' "${gone[@]}"

  if [[ "$1" != "-f" ]]; then
    read -q "?Delete these ${#gone} branch(es)? [y/N] " || { echo; return 0; }
    echo
  fi

  # -D: squash/rebase-merged branches aren't seen as merged by git.
  git branch -D "${gone[@]}"
}
