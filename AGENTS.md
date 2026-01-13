# Ralph Agent Instructions

## Overview

Ralph is an autonomous AI agent loop that runs Cursor repeatedly until all PRD items are complete. Each iteration is a fresh Cursor instance with clean context.

## Commands

```bash
# Run Ralph (from your project that has prd.json)
./ralph.sh [max_iterations]
```

## Key Files

- `ralph.sh` - The bash loop that spawns fresh Cursor instances
- `prompt.md` - Instructions given to each Cursor instance
- `prd.json.example` - Example PRD format

## Patterns

- Each iteration spawns a fresh Cursor instance with clean context
- Memory persists via git history, `progress.txt`, and `prd.json`
- Stories should be small enough to complete in one context window
- Always update AGENTS.md with discovered patterns for future iterations

## Skills

This project includes structured instruction sets (skills) in the `skills/` directory. These are detailed methodologies and guidelines that can guide agent behavior.

**To reference a skill in Cursor IDE:**
- Use `@skills/<skill-name>/SKILL.md` to reference a skill file
- Ask the agent to read the skill file for instructions
- See `SKILLS.md` for a complete list of available skills

**Available skills include:**
- `prd` - Generate Product Requirements Documents
- `ralph` - Convert PRDs to JSON format
- `build-feature` - Autonomous feature implementation loop
- `compound-engineering` - Plan → Work → Review → Compound workflow
- `frontend-design` - Production-grade frontend design guidelines
- And more (see `SKILLS.md` for complete list)
