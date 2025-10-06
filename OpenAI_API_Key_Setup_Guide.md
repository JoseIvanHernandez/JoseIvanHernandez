# OpenAI API Key Setup Guide for VS Code
*Secure Configuration for GitHub Copilot and OpenAI Extensions*

## 🔐 Current Extensions Detected
- ✅ GitHub Copilot (installed)
- ✅ GitHub Copilot Chat (installed)
- ✅ IntelliCode (installed)

## 🧭 Method 1: VS Code Settings (Recommended)

### For GitHub Copilot:
1. Open VS Code Settings (`Ctrl + ,`)
2. Search for: `github.copilot.enable`
3. Ensure it's enabled

**Note**: GitHub Copilot uses your GitHub account authentication, not a separate OpenAI API key.

### For OpenAI Extensions (if you install them):
1. Search for: `openai.apiKey` or `chatgpt.apiKey`
2. Enter your key: `sk-xxxxxxxxxxxxxxxxxx`

## 🗂️ Method 2: Settings.json File

**Location**: `C:\Users\MCCLAB28102WD09\AppData\Roaming\Code\User\settings.json`

```json
{
    "github.copilot.enable": {
        "*": true,
        "yaml": true,
        "plaintext": false,
        "markdown": true
    },
    "openai.apiKey": "sk-xxxxxxxxxxxxxxxxxx",
    "chatgpt.gpt3.apiKey": "sk-xxxxxxxxxxxxxxxxxx"
}
```

## 🧩 Method 3: Environment Variables (Most Secure)

### PowerShell Setup:
```powershell
# Set permanently for your user account
setx OPENAI_API_KEY "sk-xxxxxxxxxxxxxxxxxx"

# Verify it was set
echo $env:OPENAI_API_KEY

# Restart VS Code after setting
```

### Usage in Code:
```python
import os
api_key = os.getenv("OPENAI_API_KEY")

# Never do this:
# api_key = "sk-hardcoded-key-here"  # 🚫 DANGEROUS
```

```csharp
using System;

string apiKey = Environment.GetEnvironmentVariable("OPENAI_API_KEY");

// Never do this:
// string apiKey = "sk-hardcoded-key-here";  // 🚫 DANGEROUS
```

## 🛡️ Security Best Practices

### ✅ DO:
- Store keys in VS Code user settings
- Use environment variables for production
- Add `.env` to `.gitignore`
- Rotate keys regularly

### 🚫 DON'T:
- Commit keys to GitHub/OneDrive
- Put keys in code files
- Share keys in Discord/Slack
- Use keys in public repositories

## 📁 Safe Directory Structure

```
📁 Your Workspace/
├── .gitignore              ← Include *.env, *.key
├── README.md
├── src/
│   ├── SuperBrain.cs       ← ✅ No keys here
│   ├── Character.cs        ← ✅ No keys here
│   └── CharacterWrapper.cs ← ✅ No keys here
└── .env.example            ← Template without real keys
```

## 🔧 Popular Extensions Settings

```vscode-extensions
genieai.chatgpt-vscode,openai.chatgpt,danielsanmedium.dscodegpt
```

For these extensions, the typical settings are:
- `chatgpt.apiKey`
- `openai.apiKey` 
- `genie.openai.apiKey`

## 🚨 If Your Key Gets Compromised

1. **Immediately revoke** at: https://platform.openai.com/api-keys
2. **Generate new key** 
3. **Update all locations** where you stored it
4. **Check usage logs** for unauthorized activity

---

**Remember**: Your GitHub Copilot subscription through GitHub handles authentication automatically - you typically don't need a separate OpenAI API key unless you're using additional extensions or building custom integrations.
