# Triggers
compile, error CS, build, compilation

# Unity C# Compilation Errors — Diagnosis and Fixes

## Overview

This knowledge base helps diagnose and fix common C# compilation errors in headless Unity environments.

After running `bash /unity-compile.sh`, check `/tmp/unity-compile-status.json` for error details. This document maps error codes to solutions.

## Common Error Codes

### CS0246: Type or namespace name not found

**Error message example:**
```
error CS0246: The type or namespace name 'MyClass' could not be found (are you missing a using directive or an assembly reference?)
```

**Cause:** You referenced a type or namespace that doesn't exist or isn't imported.

**Fixes:**
1. Check the spelling of the type name (case-sensitive)
2. Add the missing `using` statement at the top of your file:
   ```csharp
   using UnityEngine;
   using UnityEngine.UI;
   ```
3. Ensure the class/namespace is in the correct assembly
4. Check that any custom classes are defined in other .cs files in `/workspace/Assets/Scripts/`

**Example:**
```csharp
// ❌ Missing using
void OnGUI()
{
    GUILayout.Button("Click me");  // ERROR: GUILayout not found
}

// ✅ Fixed
using UnityEngine;

void OnGUI()
{
    GUILayout.Button("Click me");  // OK
}
```

---

### CS1061: Object doesn't contain a definition

**Error message example:**
```
error CS1061: 'GameObject' does not contain a definition for 'FindByName' and no accessible extension method 'FindByName' accepting a first argument of type 'GameObject' could be found
```

**Cause:** You called a method or accessed a property that doesn't exist on that object.

**Fixes:**
1. Check the correct method name (case-sensitive):
   - `GameObject.Find()` ← correct
   - `GameObject.FindByName()` ← doesn't exist
2. Check Unity API documentation for the correct method signature
3. Ensure the object type is what you think it is

**Common mistakes:**
| Wrong | Correct |
|-------|---------|
| `gameObject.GetComponent(typeof(Rigidbody))` | `gameObject.GetComponent<Rigidbody>()` |
| `transform.FindChild("name")` | `transform.Find("name")` |
| `gameObject.instantiate()` | `Instantiate(gameObject)` |

---

### CS0103: Name doesn't exist in current context

**Error message example:**
```
error CS0103: The name 'speed' does not exist in the current context
```

**Cause:** You referenced a variable that hasn't been declared or is out of scope.

**Fixes:**
1. Check spelling (case-sensitive)
2. Ensure the variable is declared before use:
   ```csharp
   float speed = 5f;  // Declare first
   rigidbody.velocity = speed;  // Then use
   ```
3. Check variable scope — is it in a local block or a class field?
4. Use `public` or `private` for class-level variables:
   ```csharp
   private float speed = 5f;  // OK — accessible in all methods
   ```

---

### CS0234: Namespace doesn't contain type

**Error message example:**
```
error CS0234: The type or namespace name 'UI' does not exist in the namespace 'UnityEngine' (are you missing an assembly reference?)
```

**Cause:** You're using the wrong namespace or the assembly isn't loaded.

**Fixes:**
1. Use the correct namespace — check Unity documentation:
   ```csharp
   using UnityEngine.UI;  // Correct for UI components
   ```
2. Ensure you're importing from the right assembly
3. Some types are in different namespaces:
   - UI elements: `UnityEngine.UI`
   - Physics: `UnityEngine.Physics`
   - Networking: `UnityEngine.Networking`

---

## Reading the Status JSON

After compilation, check `/tmp/unity-compile-status.json`:

```bash
cat /tmp/unity-compile-status.json
```

Example output with errors:
```json
{
  "status": "errors",
  "errors": [
    "error CS0246: The type or namespace name 'MyClass' could not be found",
    "error CS1061: 'GameObject' does not contain a definition for 'FindByName'"
  ],
  "timestamp": "2026-02-28T14:30:00Z"
}
```

**Each error string contains:**
- Error code (CS####)
- Error type (error/warning)
- Full error message
- Source file and line number (if available)

## General Debugging Approach

For unknown errors:

1. **Extract the error code** (e.g., CS0246)
2. **Search this document** for that code
3. **If not found**, search the [Microsoft C# Compiler Error Reference](https://docs.microsoft.com/en-us/dotnet/csharp/misc/)
4. **Check the source file** mentioned in the error
5. **Recompile** after fixes: `bash /unity-compile.sh`

## Fix and Verify Cycle

1. Read the error from status JSON
2. Edit the offending .cs file in `/workspace/Assets/Scripts/`
3. Recompile: `bash /unity-compile.sh`
4. Verify success: `cat /tmp/unity-compile-status.json | grep '"status"'`
5. Repeat until `"status": "success"`

## Tips

- **First error is most important** — Fix the first error in the list, then recompile (later errors may be cascading)
- **Use IntelliSense offline** — Learn the Unity API by reading inline documentation in Visual Studio Code
- **Split complex code** — Smaller functions compile faster and are easier to debug
- **Always compile after changes** — Don't wait; verify success immediately
