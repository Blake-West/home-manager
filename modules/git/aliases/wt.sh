# git wt [-c|--create] <branch> [start_point]
# Worktrees land in .worktrees/<branch> so they sit inside the repo but out of
# the way. git appends "$@" to the alias, which is what feeds args into f.
f() {
  local create_new=false
  local branch=""
  local start_point=""

  while [ $# -gt 0 ]; do
    case "$1" in
      -b|-c|--create)
        create_new=true
        shift
        ;;
      *)
        if [ -z "$branch" ]; then
          branch="$1"
        else
          start_point="$1"
        fi
        shift
        ;;
    esac
  done

  if [ -z "$branch" ]; then
    echo "Error: Branch name is required."
    echo "Usage: git wt [-c|--create] <branch_name> [start_point]"
    return 1
  fi

  # start_point is deliberately unquoted: empty must expand to no argument.
  if [ "$create_new" = true ]; then
    git worktree add -b "$branch" ".worktrees/$branch" $start_point
  else
    git worktree add ".worktrees/$branch" "$branch"
  fi
}; f
