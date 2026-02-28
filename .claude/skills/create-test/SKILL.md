---
description: "Create validation scripts and tests for DreamForge"
---

# /create-test $ARGUMENTS

Create validation or tests for the specified component.

## Steps

1. Read the target file/component to understand what needs testing
2. Determine the test type:
   - **Shell scripts**: `bash -n` syntax + shellcheck
   - **Docker**: compose config validation, Dockerfile lint
   - **Python (OpenHands)**: pytest tests
   - **Integration**: end-to-end sandbox creation test

3. Create appropriate test/validation:
   - For shell scripts: create a `scripts/validate.sh` that runs all checks
   - For Python: create test file in `openhands/tests/`
   - For Docker: add validation step to deploy.sh

4. Run the validation to verify it works
5. Ensure validation is repeatable and automated
