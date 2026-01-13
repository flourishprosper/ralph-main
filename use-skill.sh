#!/bin/bash
# Use a skill with Cursor CLI
# 
# This script loads a skill file (structured instruction set) and combines it with
# your prompt, then runs the Cursor CLI agent. Skills are markdown files in the
# skills/ directory that contain detailed instructions for how to approach tasks.
#
# Usage: ./use-skill.sh <skill-name> [additional prompt text]
#
# Example: ./use-skill.sh prd "create a PRD for a task priority feature"
# Example: ./use-skill.sh frontend-design "build a login page"

# Exit immediately if any command fails
set -e

# Check if user provided at least the skill name
# If not, show usage and list available skills
if [ $# -lt 1 ]; then
  echo "Usage: $0 <skill-name> [additional prompt text]"
  echo ""
  echo "Available skills:"
  # List all skill directories by finding SKILL.md files and extracting the skill name
  # Format: skills/<name>/SKILL.md -> "<name>"
  ls -1 skills/*/SKILL.md 2>/dev/null | sed 's|skills/\([^/]*\)/SKILL.md|  - \1|' || echo "  (no skills found)"
  exit 1
fi

# Extract the skill name from the first argument
SKILL_NAME=$1
# Shift arguments so $* will contain everything after the skill name
shift
# Combine all remaining arguments into the user's prompt
USER_PROMPT="$*"

# Get the directory where this script is located (so it works from any location)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Build the path to the skill file (e.g., skills/prd/SKILL.md)
SKILL_FILE="$SCRIPT_DIR/skills/$SKILL_NAME/SKILL.md"

# Check if the skill file exists
if [ ! -f "$SKILL_FILE" ]; then
  echo "Error: Skill '$SKILL_NAME' not found at $SKILL_FILE"
  echo ""
  echo "Available skills:"
  # List available skills again for user reference
  ls -1 skills/*/SKILL.md 2>/dev/null | sed 's|skills/\([^/]*\)/SKILL.md|  - \1|' || echo "  (no skills found)"
  exit 1
fi

# Extract skill description from the YAML frontmatter at the top of the skill file
# Skills have frontmatter like: ---\ndescription: "..."\n---
# This extracts the description line and removes the quotes
SKILL_DESC=$(grep -A 1 "^description:" "$SKILL_FILE" | head -2 | tail -1 | sed 's/^description: *"//;s/"$//' || echo "")

# Display which skill is being used
echo "Using skill: $SKILL_NAME"
if [ -n "$SKILL_DESC" ]; then
  echo "Description: $SKILL_DESC"
fi
echo ""

# Read the skill file content, skipping the YAML frontmatter block
# The frontmatter is between two "---" lines
# awk command: match "---" lines, increment a counter, skip lines until counter > 0
# This effectively skips everything before and including the first "---",
# then outputs everything after it (the actual skill instructions)
SKILL_CONTENT=$(awk '/^---$/{if(seen++)next} seen' "$SKILL_FILE" || cat "$SKILL_FILE")

# Combine the skill content with the user's prompt
# If user provided a prompt, append it after the skill instructions
# If no prompt, just use the skill content as-is
if [ -n "$USER_PROMPT" ]; then
  FULL_PROMPT="$SKILL_CONTENT

---

User request: $USER_PROMPT"
else
  FULL_PROMPT="$SKILL_CONTENT"
fi

# Run the Cursor CLI agent with the combined prompt
# -p: print mode (non-interactive, for scripts)
# --output-format text: output as plain text
# --force: force allow commands unless explicitly denied
# "$FULL_PROMPT": the combined skill instructions + user prompt
agent -p --output-format text --force "$FULL_PROMPT"
