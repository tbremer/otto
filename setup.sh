#!/bin/bash
# Otto setup — creates symlinks to ~/.config/opencode/

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/opencode"

echo "Otto Setup"
echo "=========="
echo ""

# Create config dirs if needed
mkdir -p "$CONFIG_DIR/commands"
mkdir -p "$CONFIG_DIR/agents"

# Symlink each command individually (otto-*.md files)
for cmd in "$SCRIPT_DIR/commands"/otto-*.md; do
  if [ -f "$cmd" ]; then
    name=$(basename "$cmd")
    if [ -L "$CONFIG_DIR/commands/$name" ]; then
      rm "$CONFIG_DIR/commands/$name"
    elif [ -f "$CONFIG_DIR/commands/$name" ]; then
      echo "WARNING: $CONFIG_DIR/commands/$name exists and is not a symlink. Skipping."
      continue
    fi
    ln -s "$cmd" "$CONFIG_DIR/commands/$name"
    echo "✓ Linked commands/$name"
  fi
done

# Symlink each agent individually (otto-*.md files)
for agent in "$SCRIPT_DIR/agents"/otto-*.md; do
  if [ -f "$agent" ]; then
    name=$(basename "$agent")
    if [ -L "$CONFIG_DIR/agents/$name" ]; then
      rm "$CONFIG_DIR/agents/$name"
    elif [ -f "$CONFIG_DIR/agents/$name" ]; then
      echo "WARNING: $CONFIG_DIR/agents/$name exists and is not a symlink. Skipping."
      continue
    fi
    ln -s "$agent" "$CONFIG_DIR/agents/$name"
    echo "✓ Linked agents/$name"
  fi
done

echo ""
echo "Otto installed!"
echo ""
echo "Commands available:"
echo "  /otto-init     — Initialize a project"
echo "  /otto-plan     — Create execution plans"
echo "  /otto-discover — Map existing codebase"
echo "  /otto-research — Deep research on unknowns"
echo "  /otto-exec     — Execute a plan"
echo "  /otto-progress — Show work tree and progress"
echo "  /otto-summarize — Snapshot of codebase and context"
echo ""
