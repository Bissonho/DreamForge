---
paths:
  - "microagents/**"
---

# Microagent Rules

## What Are Microagents
- Markdown files that OpenHands agents read for context about the project
- `microagents/repo.md` — global instructions loaded for every session
- `microagents/knowledge/*.md` — triggered by keywords in conversation

## repo.md
- MUST explain headless-only mode clearly
- MUST document the init → edit → compile → verify workflow
- MUST list what's allowed and what's forbidden
- Keep concise — agents work better with clear, numbered steps

## Knowledge Files
- Each file starts with trigger keywords: `# Triggers: keyword1, keyword2`
- Content is loaded when agent conversation matches trigger keywords
- Focus on actionable information: error codes → specific fixes
- Include examples and code snippets

## Unity-Specific Knowledge
- `unity-compilation.md` — C# errors (CS0246, CS1061, CS0103, CS0234)
- `unity-editor.md` — project structure, batchmode CLI, .meta files

## Anti-Patterns
- NEVER reference GUI tools in microagents — headless only
- NEVER make instructions vague ("handle errors properly") — be specific
- NEVER assume the agent remembers previous sessions — every session starts fresh
- NEVER put secrets or API keys in microagent files
