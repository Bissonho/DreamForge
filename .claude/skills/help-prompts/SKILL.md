---
description: "Show useful prompt examples for working with DreamForge"
---

# /help-prompts

Here are effective prompts for working with DreamForge:

## Exploration
- "How does OpenHands create a sandbox container?"
- "Trace the flow from user message to agent action in OpenHands"
- "How do microagents get loaded into a session?"
- "What happens when compile-watcher detects an error?"

## Unity Sandbox
- "Add a new Unity tool to the sandbox image"
- "Improve compile-watcher to detect more error patterns"
- "Add a new microagent for Unity testing"
- "Update unity-init.sh to support a new license type"

## OpenHands Customization
- "Add a Unity compilation status panel to the UI"
- "Add a /compile button to the OpenHands chat interface"
- "Create a new API endpoint for compilation status"
- "Customize the sandbox creation to auto-run unity-init.sh"

## Infrastructure
- "Deploy DreamForge to the Hetzner server"
- "Check resource usage on the server"
- "Add a new env var to docker-compose"
- "Update the Unity version in the sandbox image"

## Complex Tasks
- "Plan DreamCI → DreamForge integration (build failure → fix session)"
- "Add multi-session monitoring dashboard"
- "Implement resource limits per user"

## Tips
- Use **Plan Mode** (Shift+Tab) before complex multi-file changes
- Use `/clear` between unrelated tasks
- Use `/review-code` before committing
- OpenHands changes require `docker compose build openhands` to take effect
