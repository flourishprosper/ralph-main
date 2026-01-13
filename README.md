# Ralph

![Ralph](ralph.webp)

Ralph is an autonomous AI agent loop that runs [Cursor](https://cursor.com) repeatedly until all PRD items are complete. Each iteration is a fresh Cursor instance with clean context. Memory persists via git history, `progress.txt`, and `prd.json`.

Based on [Geoffrey Huntley's Ralph pattern](https://ghuntley.com/ralph/).


## Prerequisites

- [Cursor CLI](https://cursor.com) installed and authenticated
- `jq` installed (`brew install jq` on macOS)
- A git repository for your project

## Setup

### Copy to your project

Copy the ralph files into your project:

```bash
# From your project root
mkdir -p scripts/ralph
cp /path/to/ralph/ralph.sh scripts/ralph/
cp /path/to/ralph/prompt.md scripts/ralph/
chmod +x scripts/ralph/ralph.sh
```

### Add "skills" as User Commands in Cursor

Run the sync script to create Cursor User Commands from the skills directory:

```bash
./sync-skills-to-commands.sh
```

This creates wrapper commands in `~/.cursor/commands/` that reference the skill files. You can then use skills directly in Cursor IDE with `/<skill-name>`.

The script supports two modes:
- `--reference` (default): Creates wrapper commands that reference skill files (recommended - keeps skills as source of truth)
- `--copy`: Copies skill content to commands (creates duplicates that need maintenance)

## Workflow

### 1. Create a PRD

Use the PRD skill to generate a detailed requirements document:

```
/prd create a PRD for [your feature description]
```

Answer the clarifying questions. The skill saves output to `tasks/prd-[feature-name].md`.

### 2. Convert PRD to Ralph format

Use the Ralph "skill" to convert the markdown PRD to JSON:

```
/ralph convert tasks/prd-[feature-name].md to prd.json
```

This creates `prd.json` with user stories structured for autonomous execution.

### 3. Run Ralph

```bash
./scripts/ralph/ralph.sh [max_iterations]
```

Default is 10 iterations.

Ralph will:
1. Archive previous run if `branchName` changed (see Archiving section)
2. Create a feature branch (from PRD `branchName`) or check it out if it exists
3. Pick the highest priority story where `passes: false`
4. Read `progress.txt` (especially the Codebase Patterns section) for context
5. Implement that single story
6. Run quality checks (typecheck, lint, tests - whatever your project requires)
7. Update `AGENTS.md` files if reusable patterns were discovered
8. If checks pass, commit ALL changes with message: `feat: [Story ID] - [Story Title]`
9. Update `prd.json` to mark story as `passes: true`
10. Append learnings to `progress.txt` (and consolidate patterns at the top if needed)
11. Repeat until all stories pass or max iterations reached

## Key Files

| File | Purpose |
|------|---------|
| `ralph.sh` | The bash loop that spawns fresh Cursor instances |
| `prompt.md` | Instructions given to each Cursor instance |
| `prd.json` | User stories with `passes` status (the task list) |
| `prd.json.example` | Example PRD format for reference |
| `progress.txt` | Append-only learnings for future iterations |
| `skills/` | Structured instruction sets (skills) for guiding AI behavior |
| `use-skill.sh` | CLI script to use skills with Cursor CLI agent |
| `sync-skills-to-commands.sh` | Create Cursor User Commands from /skills directory |
| `.last-branch` | Tracks last branch name for automatic archiving |
| `archive/` | Directory where previous runs are automatically archived |

## Skills System

Ralph includes a structured skills system - detailed instruction sets that guide AI agent behavior. Skills are markdown files with YAML frontmatter containing methodologies, guidelines, and examples.

### Using Skills

**In Cursor IDE (Chat/Agent):**
- Use `/<skill-name>` to reference a skill (after running `sync-skills-to-commands.sh`)
- Skills are automatically loaded when referenced

**Via CLI:**
```bash
./use-skill.sh <skill-name> [additional prompt text]
```

Example:
```bash
./use-skill.sh prd "create a PRD for a task priority feature"
./use-skill.sh frontend-design "build a login page"
```

The script loads the skill file, combines it with your prompt, and runs the Cursor CLI agent.

### Available Skills

See `SKILLS.md` for the complete list. Available skills include:

- **prd** - Generate Product Requirements Documents with structured methodology
- **ralph** - Convert markdown PRDs to `prd.json` format for autonomous execution
- **build-feature** - Autonomous task execution loop for implementing features
- **compound-engineering** - Plan → Work → Review → Compound workflow
- **frontend-design** - Production-grade frontend design guidelines
- **pdf** - Comprehensive PDF manipulation toolkit (extract, create, merge, split, forms)
- **docx** - Document creation, editing, and analysis with tracked changes

### Skill File Structure

Skills follow a consistent structure:
1. **YAML Frontmatter**: Contains name, description, and metadata
2. **Instructions**: Detailed methodology and guidelines
3. **Examples**: Code examples, patterns, and use cases
4. **Checklists**: Verification steps and requirements

## Critical Concepts

### Each Iteration = Fresh Context

Each iteration spawns a **new Cursor instance** with clean context. The only memory between iterations is:
- Git history (commits from previous iterations)
- `progress.txt` (learnings and context)
- `prd.json` (which stories are done)

### Small Tasks

Each PRD item should be small enough to complete in one context window. If a task is too big, the LLM runs out of context before finishing and produces poor code.

Right-sized stories:
- Add a database column and migration
- Add a UI component to an existing page
- Update a server action with new logic
- Add a filter dropdown to a list

Too big (split these):
- "Build the entire dashboard"
- "Add authentication"
- "Refactor the API"

### AGENTS.md Updates Are Critical

After each iteration, Ralph updates the relevant `AGENTS.md` files with learnings. This is key because Cursor automatically reads these files, so future iterations (and future human developers) benefit from discovered patterns, gotchas, and conventions.

**When to update AGENTS.md:**
- When you discover reusable patterns specific to a module or directory
- When you encounter gotchas that future work should avoid
- When you find dependencies between files that aren't obvious
- When you establish testing approaches for a specific area

**Examples of what to add to AGENTS.md:**
- Patterns discovered ("this codebase uses X for Y")
- Gotchas ("do not forget to update Z when changing W")
- Useful context ("the settings panel is in component X")
- API patterns or conventions specific to that module
- Configuration or environment requirements

**Do NOT add:**
- Story-specific implementation details
- Temporary debugging notes
- Information already in progress.txt

### Codebase Patterns Consolidation

Ralph consolidates the most important learnings in a `## Codebase Patterns` section at the TOP of `progress.txt`. This section should contain general, reusable patterns (not story-specific details).

Examples:
- Use `sql<number>` template for aggregations
- Always use `IF NOT EXISTS` for migrations
- Export types from actions.ts for UI components

Only add patterns that are **general and reusable**, not story-specific details.

### Feedback Loops

Ralph only works if there are feedback loops:
- Typecheck catches type errors
- Tests verify behavior
- CI must stay green (broken code compounds across iterations)

### Browser Verification for UI Stories

Frontend stories must include "Verify in browser using dev-browser skill" in acceptance criteria. Ralph will use browser automation tools to:
- Navigate to the relevant page
- Interact with the UI to verify changes work
- Take screenshots if helpful for documentation
- Confirm functionality matches acceptance criteria

A frontend story is NOT complete until browser verification passes.

### Stop Condition

When all stories have `passes: true`, Ralph outputs `<promise>COMPLETE</promise>` and the loop exits.

## Debugging

Check current state:

```bash
# See which stories are done
cat prd.json | jq '.userStories[] | {id, title, passes}'

# See learnings from previous iterations
cat progress.txt

# Check git history
git log --oneline -10
```

## Customizing prompt.md

Edit `prompt.md` to customize Ralph's behavior for your project:
- Add project-specific quality check commands
- Include codebase conventions
- Add common gotchas for your stack

## Archiving

Ralph automatically archives previous runs when you start a new feature (different `branchName`). 

**How it works:**
1. Ralph tracks the last branch name in `.last-branch`
2. When you start a new feature with a different `branchName` in `prd.json`, it detects the change
3. It automatically archives the previous run's `prd.json` and `progress.txt` files
4. Archives are saved to `archive/YYYY-MM-DD-feature-name/`
5. The `progress.txt` file is reset for the new feature

This ensures you don't lose previous work and can reference past iterations when needed.

## References

- [Geoffrey Huntley's Ralph article](https://ghuntley.com/ralph/)
- [Cursor documentation](https://cursor.com/manual)
- [Snarktank] (https://github.com/snarktank)