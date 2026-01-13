# Available Skills

This directory contains structured instruction sets (skills) that can be used to guide AI agent behavior. Skills are detailed markdown files with methodologies, guidelines, and examples.

## How to Use Skills

### In Cursor IDE (Chat/Agent)
1. **Reference directly**: Use `/<skill-name>` to reference a skill file


## Available Skills

### prd
**Location**: `/prd`
**Description**: Generate Product Requirements Documents (PRDs) for features. Provides structured methodology for creating detailed, actionable requirements with user stories, acceptance criteria, and functional requirements.
**Use when**: Planning features, creating requirements documents, starting new projects

### ralph
**Location**: `/ralph`
**Description**: Convert markdown PRDs to `prd.json` format for the Ralph autonomous agent system. Ensures proper story sizing, dependency ordering, and verifiable acceptance criteria.
**Use when**: Converting PRDs to JSON format for Ralph execution

### build-feature
**Location**: `/build-feature`
**Description**: Autonomous task execution loop that implements tasks one by one until complete. Provides guidance on task sizing, progress tracking, and systematic implementation.
**Use when**: Building features autonomously, running implementation loops

### compound-engineering
**Location**: `/compound-engineering`
**Description**: Compound Engineering workflow following Plan → Work → Review → Compound loop. Each unit of work makes subsequent work easier through systematic documentation and learning.
**Use when**: Planning features, executing work, reviewing code, codifying learnings

### frontend-design
**Location**: `/frontend-design`
**Description**: Create distinctive, production-grade frontend interfaces with high design quality. Provides guidelines for avoiding generic AI aesthetics through intentional design choices, typography, color, motion, and spatial composition.
**Use when**: Building web components, pages, or applications with attention to design quality

### pdf
**Location**: `/pdf`
**Description**: Comprehensive PDF manipulation toolkit for extracting text and tables, creating new PDFs, merging/splitting documents, and handling forms.
**Use when**: Filling PDF forms or programmatically processing, generating, or analyzing PDF documents at scale

### docx
**Location**: `/docx`
**Description**: Comprehensive document creation, editing, and analysis with support for tracked changes, comments, formatting preservation, and text extraction.
**Use when**: Creating new documents, modifying or editing content, working with tracked changes, adding comments, or any other document tasks with .docx files

## Skill File Structure

Skills follow a consistent structure:
1. **YAML Frontmatter**: Contains name, description, and metadata
2. **Instructions**: Detailed methodology and guidelines
3. **Examples**: Code examples, patterns, and use cases
4. **Checklists**: Verification steps and requirements

## Adding New Skills

To add a new skill:
1. Create a directory: `skills/<skill-name>/`
2. Add `SKILL.md` with frontmatter and instructions
3. Update this `SKILLS.md` file with the new skill's information
4. Run sync-skills-to-commands.sh
