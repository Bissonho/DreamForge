---
name: prd
description: "Generate a Product Requirements Document (PRD) for a DreamForge feature."
user-invocable: true
---

# PRD Generator — DreamForge

Create detailed Product Requirements Documents for DreamForge features.

---

## The Job

1. Receive a feature description from the user
2. Ask 3-5 essential clarifying questions (with lettered options)
3. Generate a structured PRD based on answers
4. Save to `tasks/prd-[feature-name].md`

**Important:** Do NOT start implementing. Just create the PRD.

---

## Step 1: Clarifying Questions

Ask only critical questions. Focus on:
- **Problem/Goal:** What problem does this solve?
- **Core Functionality:** What are the key actions?
- **Scope/Boundaries:** What should it NOT do?
- **Layer:** OpenHands UI? Backend? Sandbox? Microagents?

---

## Step 2: PRD Structure

### 1. Introduction/Overview
### 2. Goals
### 3. User Stories (US-001 format, small, verifiable)
### 4. Functional Requirements (FR-1 format)
### 5. Non-Goals
### 6. Technical Considerations
### 7. Success Metrics
### 8. Open Questions

---

## DreamForge-Specific Acceptance Criteria

Always include as final criteria for each story:
```
"bash -n passes on all modified shell scripts"
"docker compose config --quiet passes (if compose modified)"
```

For OpenHands Python changes:
```
"python3 -m py_compile passes on modified files"
```
