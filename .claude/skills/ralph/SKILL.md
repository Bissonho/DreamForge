---
name: ralph
description: "Convert PRDs to prd.json format for the Ralph autonomous agent system."
user-invocable: true
---

# Ralph PRD Converter — DreamForge

Converts existing PRDs to the prd.json format that Ralph uses for autonomous execution.

---

## Output Format

```json
{
  "project": "DreamForge",
  "branchName": "ralph/[feature-name-kebab-case]",
  "description": "[Feature description]",
  "userStories": [
    {
      "id": "US-001",
      "title": "[Story title]",
      "description": "As a [user], I want [feature] so that [benefit]",
      "acceptanceCriteria": [
        "Criterion 1",
        "bash -n passes on all modified shell scripts",
        "docker compose config --quiet passes"
      ],
      "priority": 1,
      "passes": false,
      "notes": "",
      "model": "sonnet"
    }
  ]
}
```

---

## DreamForge Quality Checks

Always include as final criteria:

For shell script stories:
```
"bash -n passes on all modified shell scripts"
```

For Docker stories:
```
"docker compose config --quiet passes"
```

For OpenHands Python stories:
```
"python3 -m py_compile passes on modified files"
```

---

## Story Size

Each story must be completable in ONE Ralph iteration (one context window).

### Right-sized:
- Add a shell script helper
- Modify Dockerfile to add a package
- Create a microagent knowledge file
- Add an env var to docker-compose

### Too big (split):
- "Customize the entire OpenHands UI" → split by component
- "Add DreamCI integration" → split by endpoint/feature

---

## Model Selection

| Model | When to use |
|-------|-------------|
| `opus` | Complex: multi-file OpenHands changes, new architecture |
| `sonnet` | Standard: single feature, Dockerfile, docker-compose |
| `haiku` | Simple: single script, microagent, markdown |

---

## Output location

Save to `scripts/ralph/prd.json`
