---
title: 'Lab 14.1 – Write troubleshooting scripts with AI'
lab:
    title: 'Lab 14.1 – Write troubleshooting scripts with AI'
    module: 'Day 3 – Advanced troubleshooting and scripting'
---

# Lab 14.1 – Write troubleshooting scripts with AI

**Estimated time:** 60 minutes

> **Draft:** This lab is new and has not been run in this environment yet. If a step behaves differently, tell the trainer.

**Goal:** Turn a support question into a read-only PowerShell script with Copilot Chat – and prove that the script is correct before you trust its answer.

**Starting point:** Copilot Chat has no access to your tenant, your devices or Intune. It knows only what you paste into the prompt. Never paste passwords, tokens, tenant IDs or user data.

### Part A – Prompt

1. CL3: open Microsoft Edge, sign in with `studentX` and open Copilot Chat at `https://copilot.cloud.microsoft`. Check that you are in the **Work** experience.
2. Pick one question your toolbox from Lab 13.1 does not answer, for example:
   - Which Windows devices in `studentXdevices` haven't synced for more than 7 days?
   - Which settings catalog policies contain a setting with `BitLocker` in its name, and to which groups are they assigned?
   - On which devices did the detection script of `studentX-Reg` report an issue in the last 24 hours?
3. Write the prompt with these five parts:

   | Part | Example |
   |---|---|
   | Goal | "Write a Windows PowerShell 5.1 script that lists …" |
   | Interface | "Use Microsoft Graph with `Invoke-MgGraphRequest` from `Microsoft.Graph.Authentication`, no other Graph modules." |
   | Permissions | "Delegated sign-in with `Connect-MgGraph`, read-only scopes only, name every scope you use." |
   | Safety | "Only GET requests. Handle paging with `@odata.nextLink`." |
   | Output | "Export a CSV with delimiter `;` and UTF-8. Comment every Graph URL." |

4. Save the answer as `C:\Toolbox\AI\Get-MyAnswer.ps1`. Don't run it yet.

### Part B – Prove it before you run it

5. Static check:

   ```powershell
   Install-Module PSScriptAnalyzer -Scope CurrentUser -Force
   Invoke-ScriptAnalyzer -Path C:\Toolbox\AI\Get-MyAnswer.ps1
   ```

6. Every Graph URL in the script: does it exist, and which permission does it need?

   ```powershell
   Find-MgGraphCommand -Uri '/deviceManagement/managedDevices' -Method GET | Select-Object -First 1 -ExpandProperty Permissions
   ```

   Compare with the Microsoft Graph API reference on Microsoft Learn: endpoint, `v1.0` or `beta`, property names in `$select` and `$filter`.
7. Paste each URL into Graph Explorer (Lab 10.1) with method **GET** – does it return what the script expects?
8. Search the script for anything that writes: `POST`, `PATCH`, `PUT`, `DELETE`, `Remove-`, `Set-`, `New-`, a scope ending in `ReadWrite`. Remove it or ask Copilot to remove it.

### Part C – Run and compare

9. Run the script:

   ```powershell
   PowerShell.exe -ExecutionPolicy Bypass -File C:\Toolbox\AI\Get-MyAnswer.ps1
   ```

10. Check the result against the portal or a toolbox script for at least one device or policy.
11. Paste the first error message back into Copilot Chat – with the line of code, not with your data. Note how many rounds it took until the script was correct.

### Checkpoint

- [ ] Prompt with goal, interface, permissions, safety and output
- [ ] PSScriptAnalyzer run, findings fixed or explained
- [ ] Every Graph URL checked with `Find-MgGraphCommand` or on Learn, and in Graph Explorer
- [ ] Script contains only GET requests and Read scopes
- [ ] Result confirmed for at least one object in the portal

**Note:** Typical AI errors in Intune scripts: endpoints that exist only in `beta`, invented properties in `$select`, a missing paging loop (only the first page is processed), cmdlets from Graph modules that aren't installed, and write scopes "to be safe". The script runs with your permissions – what you can do, the script can do.

**Why:** AI writes a script in seconds. Whether it answers the support question correctly is still your job – and the check takes longer than the prompt.

<!-- VERIFY: Copilot Chat available for studentX users (E5 developer licenses), several users at the same time -->
<!-- VERIFY: Graph consent for the scopes the generated scripts request (Microsoft Graph Command Line Tools) -->
<!-- VERIFY: PSScriptAnalyzer install from PowerShell Gallery works in the pod -->
