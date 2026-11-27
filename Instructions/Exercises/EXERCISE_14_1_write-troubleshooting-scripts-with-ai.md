---
redirect_from:
  - /Instructions/Labs/LAB_14_1_write-troubleshooting-scripts-with-ai.html
title: 'Exercise 14.1 – Write troubleshooting scripts with AI'
lab:
    title: 'Exercise 14.1 – Write troubleshooting scripts with AI'
    module: 'Day 3 – Advanced troubleshooting and scripting'
---

# Exercise 14.1 – Write troubleshooting scripts with AI

**Estimated time:** 60 minutes

> **Draft:** This lab is new and has not been run in this environment yet. If a step behaves differently, tell the trainer.

**Goal:** Turn a support question into a read-only PowerShell script with Copilot Chat – and prove the script is right before you trust its answer.

**Starting point:** Copilot Chat can't see your tenant, your devices or Intune; it only knows what you paste into the prompt. Never paste passwords, tokens, tenant IDs or user data.

### Part A – Prompt

1. On CL3, open Microsoft Edge, sign in as `flaneX` and go to Copilot Chat at `https://copilot.cloud.microsoft`. Make sure you are in the **Work** experience.
2. Choose a question your toolbox from Exercise 13.2 can't answer, such as:
   - Which Windows devices in `studentXdevices` haven't synced for more than 7 days?
   - Which settings catalog policies contain a setting with `BitLocker` in its name, and to which groups are they assigned?
   - On which devices did the detection script of `flaneX-Reg` report an issue in the last 24 hours?
3. Build the prompt from these five parts:

   | Part | Example |
   |---|---|
   | Goal | "Write a Windows PowerShell 5.1 script that lists …" |
   | Interface | "Use Microsoft Graph with `Invoke-MgGraphRequest` from `Microsoft.Graph.Authentication`, no other Graph modules." |
   | Permissions | "Delegated sign-in with `Connect-MgGraph`, read-only scopes only, name every scope you use." |
   | Safety | "Only GET requests. Handle paging with `@odata.nextLink`." |
   | Output | "Export a CSV with delimiter `;` and UTF-8. Comment every Graph URL." |

4. Save the answer as `C:\Toolbox\AI\Get-MyAnswer.ps1` – but don't run it yet.

### Part B – Prove it before you run it

5. Start with a static check:

   ```powershell
   Install-Module PSScriptAnalyzer -Scope CurrentUser -Force
   Invoke-ScriptAnalyzer -Path C:\Toolbox\AI\Get-MyAnswer.ps1
   ```

6. For every Graph URL in the script, check that it exists and which permission it needs:

   ```powershell
   Find-MgGraphCommand -Uri '/deviceManagement/managedDevices' -Method GET | Select-Object -First 1 -ExpandProperty Permissions
   ```

   Cross-check with the Microsoft Graph API reference on Microsoft Learn: endpoint, `v1.0` or `beta`, and the property names in `$select` and `$filter`.
7. Paste each URL into Graph Explorer (Exercise 13.1) with method **GET** – does it return what the script expects?
8. Search the script for anything that writes: `POST`, `PATCH`, `PUT`, `DELETE`, `Remove-`, `Set-`, `New-`, or a scope ending in `ReadWrite`. Take it out, or have Copilot take it out.

### Part C – Run and compare

9. Now run the script:

   ```powershell
   PowerShell.exe -ExecutionPolicy Bypass -File C:\Toolbox\AI\Get-MyAnswer.ps1
   ```

10. Verify the result for at least one device or policy against the portal or a toolbox script.
11. Feed the first error message back into Copilot Chat – with the line of code, never with your data. Count the rounds it takes until the script is correct.

### Checkpoint

- [ ] Your prompt covers goal, interface, permissions, safety and output
- [ ] PSScriptAnalyzer ran, and its findings are fixed or explained
- [ ] Every Graph URL was checked with `Find-MgGraphCommand` or on Learn, and in Graph Explorer
- [ ] The script contains only GET requests and Read scopes
- [ ] The portal confirms the result for at least one object

### Good to know

- **Typical AI errors in Intune scripts:** endpoints that exist only in `beta`, invented properties in `$select`, a missing paging loop (so only the first page is processed), cmdlets from Graph modules that aren't installed, and write scopes "to be safe".
- **Your permissions:** the script runs as you – whatever you can do, the script can do.

**Background:** AI writes a script in seconds. Whether it answers the support question correctly remains your job – and checking takes longer than prompting.

<!-- VERIFY: Copilot Chat available for flaneX users (E5 developer licenses), several users at the same time -->
<!-- VERIFY: Graph consent for the scopes the generated scripts request (Microsoft Graph Command Line Tools) -->
<!-- VERIFY: PSScriptAnalyzer install from PowerShell Gallery works in the pod -->
