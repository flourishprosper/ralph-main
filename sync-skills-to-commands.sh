#!/bin/bash
# Sync skills to Cursor user commands
# 
# This script creates user commands in ~/.cursor/commands/ that reference
# or copy the skill files. You can either:
# 1. Create wrapper commands that reference the skill (recommended - keeps skills as source of truth)
# 2. Copy skill content to commands (creates duplicates that need maintenance)
#
# Usage: ./sync-skills-to-commands.sh [--copy|--reference]
#   --copy: Copy skill content to commands (full duplication)
#   --reference: Create wrapper commands that reference skills (default)

set -e

MODE=${1:---reference}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMANDS_DIR="$HOME/.cursor/commands"

# Create commands directory if it doesn't exist
mkdir -p "$COMMANDS_DIR"

if [ "$MODE" = "--copy" ]; then
  echo "Copying skill content to user commands..."
  
  # Copy each skill's content (skipping YAML frontmatter) to a command file
  for skill_file in "$SCRIPT_DIR"/skills/*/SKILL.md; do
    if [ -f "$skill_file" ]; then
      skill_name=$(basename $(dirname "$skill_file"))
      command_file="$COMMANDS_DIR/${skill_name}.md"
      
      # Extract skill content (skip YAML frontmatter)
      awk '/^---$/{if(seen++)next} seen' "$skill_file" > "$command_file"
      
      echo "  Created: $command_file (copied from $skill_file)"
    fi
  done
  
  echo ""
  echo "Skills copied to user commands. You can now use /<skill-name> in Cursor."
  echo "Note: These are copies - update skills in the skills/ directory and re-run this script."
  
elif [ "$MODE" = "--reference" ]; then
  echo "Creating wrapper commands that reference skills..."
  
  # Create wrapper commands that instruct the agent to read the skill file
  for skill_file in "$SCRIPT_DIR"/skills/*/SKILL.md; do
    if [ -f "$skill_file" ]; then
      skill_name=$(basename $(dirname "$skill_file"))
      command_file="$COMMANDS_DIR/${skill_name}.md"
      skill_path="$SCRIPT_DIR/skills/$skill_name/SKILL.md"
      
      # Get skill description for the wrapper
      skill_desc=$(grep -A 1 "^description:" "$skill_file" | head -2 | tail -1 | sed 's/^description: *"//;s/"$//' 2>/dev/null || echo "Use the $skill_name skill")
      
      # Create a wrapper command that tells the agent to read the skill file
      # The agent will read the skill file when this command is used
      cat > "$command_file" <<EOF
# $skill_name

$skill_desc

Read and follow the instructions from: @$skill_path
EOF
      
      echo "  Created: $command_file (references $skill_path)"
    fi
  done
  
  echo ""
  echo "Wrapper commands created. These reference the skill files as the source of truth."
  echo "In Cursor, use /<skill-name> and the agent will read the skill file."
  
else
  echo "Unknown mode: $MODE"
  echo "Usage: $0 [--copy|--reference]"
  exit 1
fi

echo ""
echo "Available commands in ~/.cursor/commands/:"
ls -1 "$COMMANDS_DIR"/*.md 2>/dev/null | sed 's|.*/|  /|;s|\.md$||' || echo "  (none)"
