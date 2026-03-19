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

# Symlink the otto commands directory
if [ -L "$CONFIG_DIR/commands/otto" ]; then
  rm "$CONFIG_DIR/commands/otto"
elif [ -d "$CONFIG_DIR/commands/otto" ]; then
  echo "WARNING: $CONFIG_DIR/commands/otto exists and is not a symlink. Skipping."
  exit 1
fi
ln -s "$SCRIPT_DIR/commands/otto" "$CONFIG_DIR/commands/otto"
echo "✓ Linked commands/otto/"

# Symlink the otto agents directory
if [ -L "$CONFIG_DIR/agents/otto" ]; then
  rm "$CONFIG_DIR/agents/otto"
elif [ -d "$CONFIG_DIR/agents/otto" ]; then
  echo "WARNING: $CONFIG_DIR/agents/otto exists and is not a symlink. Skipping."
  exit 1
fi
ln -s "$SCRIPT_DIR/agents/otto" "$CONFIG_DIR/agents/otto"
echo "✓ Linked agents/otto/"

echo ""
echo "Otto installed!"
echo ""
echo "Commands available:"
echo "  /otto/plan     — Create execution plans"
echo "  /otto/research — Deep research on unknowns"
echo "  /otto/execute  — Execute a plan"
echo ""
