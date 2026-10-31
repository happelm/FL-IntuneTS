---
title: 'Lab 16.1 – Partner breaks, you fix'
lab:
    title: 'Lab 16.1 – Partner breaks, you fix'
    module: 'Day 3 – Advanced troubleshooting and scripting'
---

# Lab 16.1 – Partner breaks, you fix

**Estimated time:** 60 minutes

> **Draft:** This lab is new and its scenarios are still being tested. If a step behaves differently, tell the trainer.

**Goal:** Find two faults you do not know – with the method of this course: scope first, then the layers on the client, then the evidence. This is the final case of the course.

**Starting point:** You work in pairs, A and B. You play two rounds. In each round both of you draw a scenario card from the trainer:

| Round | Cards from | Object name | Time |
|---|---|---|---|
| 1 | Apps, scripts, remediations, configuration (Days 1–2) | `studentX-Case1` | 25 min |
| 2 | Endpoint security, LAPS, EPM (Days 2–3) | `studentX-Case2` | 25 min |

Each card describes one Intune object with exactly one wrong setting. You build it for your partner's CL3 – your partner builds one for yours. You don't tell your partner what is on your card.

**Exception for this lab:** You assign an object to your partner's device group. That is the only time in this course you touch another participant's group.

### Each round

1. Build the object exactly as your card says, with the name for this round (your own number), and assign it to your partner's `studentYdevices`.
2. Give your partner only the helpdesk ticket from your card – not the settings.
3. Read the ticket you got and sync your CL3.
4. Scope first – which objects reach CL3 now that did not reach it before?

   ```powershell
   PowerShell.exe -ExecutionPolicy Bypass -File C:\Toolbox\Get-IntunePolicyAssignmentsByGroup.ps1 -DeviceName CL3-yourname -ExportCsv
   ```

5. Find the cause on CL3 and in the Intune admin center: IME logs, registry, event log, `Get-MpPreference`, LAPS cycle, `Get-Policies`, Device query – whatever the object type needs. Compare with what CL3 logged in your own labs.
6. Write down the root cause, the evidence (log line, event ID, registry value, cmdlet output or portal status) and the fix.
7. Check your result with your partner's card, then with the trainer.
8. Clean up: delete your `studentX-Case1` or `studentX-Case2`.

### Checkpoint

- [ ] Round 1: root cause, evidence and fix named, confirmed by your partner's card
- [ ] Round 2: root cause, evidence and fix named, confirmed by your partner's card
- [ ] The new object found with the toolbox device view in both rounds
- [ ] `studentX-Case1` and `studentX-Case2` deleted

<details markdown="1">
<summary>Hint 1 – where to start</summary>

Compare the device view CSV with the one from Lab 13.2. The new row is your partner's object – its type tells you which log to open. The log map is in the [Appendix](../Appendix.html#log-map).

</details>

<details markdown="1">
<summary>Hint 2 – compare with known-good</summary>

Open the same log for your own object from Lab 5.1, 6.1, 11.1 or 12.1. Find the first line where your partner's object behaves differently.

</details>

<details markdown="1">
<summary>Hint 3 – conflict or wrong value?</summary>

Devices → `CL3-yourname` → Device configuration: **Conflict** means two policies set the same setting. **Succeeded** means the value arrived – then the value itself is wrong. Compare every setting of the object with your own working object: exactly one setting differs.

</details>

**Note:** Your partner's object reaches CL3 like every other assignment – after a sync, an app within minutes. A remediation runs on its schedule; restart the IME if nothing shows up in `HealthScripts.log` after 5 minutes. For LAPS run `Invoke-LapsPolicyProcessing` after the sync.

**Why:** In the real world nobody tells you the cause. You know what healthy looks like – the first deviation shows you where to look.
