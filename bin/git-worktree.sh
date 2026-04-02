#!/bin/sh

if [ -z "$1" ]; then
  git worktree list
  echo "================================"
  echo "Add a new worktree:"
  echo "Usage: $0 <worktree-name> [<start-point>]"
  exit 1
fi

WORKTREE_DIR=~/worktrees/`basename $PWD`

if [ ! -d "$WORKTREE_DIR" ]; then
  mkdir -p "$WORKTREE_DIR"
fi

if [ -d "$WORKTREE_DIR/$1" ]; then
  echo "Worktree already exists: $WORKTREE_DIR/$1"
  exit 1
fi

git worktree add "$WORKTREE_DIR/$1" "${2:-origin/main}" -b $1
