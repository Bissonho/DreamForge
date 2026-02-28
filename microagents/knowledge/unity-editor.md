# Triggers
editor, unity, scene, project

# Unity Project Structure and CLI Commands

## Overview

This knowledge base explains Unity project organization and how to use the headless editor from the command line (batchmode).

In DreamForge, you work entirely via the CLI — no visual Editor window. This document covers project structure, safe directories, and useful batchmode commands.

## Project Directory Structure

### `/workspace/` — The Unity Project Root

```
/workspace/
├── Assets/                      ← Edit your code here (safe)
│   ├── Scripts/                 ← C# code files (primary workspace)
│   ├── Scenes/                  ← .unity scene files (edit if needed)
│   ├── Prefabs/                 ← Reusable game object templates
│   ├── Resources/               ← Runtime-loaded assets
│   ├── Plugins/                 ← Third-party DLLs and native code
│   └── Editor/                  ← Editor-only scripts (not included in builds)
│
├── ProjectSettings/             ← Configuration (mostly read-only)
│   ├── ProjectSettings.asset    ← Main project config
│   ├── GraphicsSettings.asset   ← Graphics configuration
│   ├── EditorSettings.asset     ← Editor preferences
│   └── TagManager.asset         ← Tags and layers
│
├── Packages/                    ← Package manifest (don't edit directly)
│   └── manifest.json            ← Package dependencies (managed by Unity)
│
├── Library/                     ← AUTO-GENERATED (DO NOT EDIT)
│   ├── ScriptAssemblies/        ← Compiled .dlls
│   ├── metadata/                ← Cache files
│   └── ...
│
├── Temp/                        ← BUILD CACHE (DO NOT EDIT)
│   └── ...
│
├── .gitignore                   ← Ignore patterns for git
├── README.md
└── ...
```

### Safe vs. Read-Only Directories

| Directory | Safe? | Notes |
|-----------|-------|-------|
| `/workspace/Assets/Scripts/` | ✅ YES | Edit your C# files here |
| `/workspace/Assets/` | ✅ YES | Edit scenes, prefabs, resources |
| `/workspace/ProjectSettings/` | ⚠️ MOSTLY READ-ONLY | Project config; avoid direct edits |
| `/workspace/Library/` | ❌ NO | Auto-generated compiled code — never edit |
| `/workspace/Temp/` | ❌ NO | Build cache; regenerated on compile |

---

## Meta Files (.meta)

Every asset in `/Assets/` has a corresponding `.meta` file that stores metadata (GUID, importer settings, etc.).

```
Assets/
├── Scripts/
│   ├── Player.cs
│   └── Player.cs.meta  ← Metadata for Player.cs
└── Textures/
    ├── bg.png
    └── bg.png.meta     ← Metadata for bg.png
```

**Important:**
- ✅ Commit `.meta` files to git (they're needed for asset references)
- ❌ Never manually edit `.meta` files (Unity regenerates them)
- ⚠️ If `.meta` files are missing, assets may lose their GUIDs and break references

---

## Batchmode CLI Commands

### Run Unity Compilation (in headless mode)

```bash
unity-editor \
    -batchmode \
    -nographics \
    -projectPath /workspace \
    -logFile /tmp/unity.log \
    -quit
```

**Flags:**
- `-batchmode` — Run without GUI
- `-nographics` — Disable rendering
- `-projectPath /workspace` — Target project directory
- `-logFile /path/to/log` — Redirect console output to file
- `-quit` — Exit after operations complete

---

### Execute a C# Method

```bash
unity-editor \
    -batchmode \
    -nographics \
    -projectPath /workspace \
    -executeMethod ClassName.MethodName \
    -quit
```

**Example:**
```bash
unity-editor \
    -batchmode \
    -nographics \
    -projectPath /workspace \
    -executeMethod BuildScript.Build \
    -quit
```

The method must be `public static` and in an `Assets/Editor/` script:

```csharp
using UnityEditor;

public class BuildScript
{
    [MenuItem("Tools/Build")]
    public static void Build()
    {
        Debug.Log("Building...");
        EditorBuildSettingsScene[] scenes = EditorBuildSettings.scenes;
        // Build logic here
    }
}
```

---

### Run Unit Tests

```bash
unity-editor \
    -batchmode \
    -nographics \
    -projectPath /workspace \
    -runTests \
    -testResults /tmp/test-results.xml \
    -quit
```

**Flags:**
- `-runTests` — Run all tests
- `-testResults /path/to/results` — Output XML test report
- `-testPlatform editmode` — Run editor-mode tests (default)
- `-testPlatform playmode` — Run play-mode tests (requires more setup)

**Test format:**
Tests must be in `Assets/Tests/` using Unity Test Framework:

```csharp
using NUnit.Framework;
using UnityEngine;

public class PlayerTests
{
    [Test]
    public void PlayerMoveForward()
    {
        var player = new GameObject().AddComponent<Player>();
        player.Move(Vector3.forward);
        Assert.AreEqual(Vector3.forward, player.transform.position);
    }
}
```

---

### Set Build Target

```bash
unity-editor \
    -batchmode \
    -nographics \
    -projectPath /workspace \
    -buildTarget linux64 \
    -quit
```

**Common targets:**
- `windows64` — Windows 64-bit
- `linux64` — Linux 64-bit
- `macosx` — macOS
- `webgl` — WebGL (browser)
- `android` — Android
- `ios` — iOS

---

## Useful Patterns

### Check if compilation succeeded

```bash
bash /unity-compile.sh
cat /tmp/unity-compile-status.json | grep '"status"'
```

Expected output on success:
```
"status": "success"
```

### View recent logs

```bash
tail -20 /root/.config/unity3d/Editor.log
```

Or (alternative location):
```bash
tail -20 /workspace/Library/Logs/Editor.log
```

### Find compilation errors

```bash
bash /unity-compile.sh
cat /tmp/unity-compile-status.json | jq '.errors'
```

### Execute custom build method and check results

```bash
unity-editor \
    -batchmode \
    -nographics \
    -projectPath /workspace \
    -executeMethod BuildScript.BuildLinux \
    -logFile /tmp/build.log \
    -quit

# Then check the log
cat /tmp/build.log
```

---

## Important Constraints in Headless Mode

- ❌ **No visual scenes:** You cannot open/edit `.unity` scene files visually
- ❌ **No prefab editor:** Prefabs are edited as text/code, not visually
- ❌ **No hierarchy drag-and-drop:** Scene setup must be done via C# or scene JSON
- ✅ **Full C# API:** All non-Editor-UI APIs are available (physics, input, animations, networking, etc.)
- ✅ **Scriptable Objects:** Create data using `ScriptableObject`s in C#

---

## Common Workflows

### Setup Scene Programmatically

```csharp
using UnityEngine;

public class SceneSetup
{
    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
    public static void SetupScene()
    {
        // Create player
        var player = new GameObject("Player");
        player.AddComponent<Player>();

        // Create camera
        var camera = new GameObject("MainCamera");
        camera.AddComponent<Camera>();
        camera.tag = "MainCamera";
    }
}
```

### Load scene by name

```csharp
using UnityEngine.SceneManagement;

SceneManager.LoadScene("GameScene");
```

### Use Resources folder for runtime assets

```csharp
var prefab = Resources.Load<GameObject>("Player");
var instance = Object.Instantiate(prefab);
```

---

## Troubleshooting

### "Editor.log not found"
Log file may be in:
```bash
ls -la /root/.config/unity3d/
ls -la /workspace/Library/Logs/
```

Check both locations; the path varies by Unity version and configuration.

### "ExecuteMethod failed: class not found"
- Ensure the class is in `Assets/Editor/` directory
- Ensure the method is `public static`
- Ensure the namespace is correct

### "Build failed silently"
- Run with `-logFile` to capture output
- Check the log file for errors
- Recompile first: `bash /unity-compile.sh`

---

## Summary

1. **Edit in:** `/workspace/Assets/Scripts/`
2. **Don't touch:** `Library/` and `Temp/`
3. **Compile:** `bash /unity-compile.sh`
4. **Run methods:** Use `-executeMethod` with `public static` methods in Editor scripts
5. **Check results:** Read status JSON or log files
6. **Commit `.meta` files** to git for asset references
