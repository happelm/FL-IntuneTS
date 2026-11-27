---
redirect_from:
  - /Instructions/Labs/LAB_16_1_partner-breaks-you-fix.html
title: 'Exercise 16.1 – Partner breaks, you fix'
lab:
    title: 'Exercise 16.1 – Partner breaks, you fix'
    module: 'Day 3 – Advanced troubleshooting and scripting'
---

# Exercise 16.1 – Partner breaks, you fix

**Estimated time:** 60 minutes

> **Draft:** This lab is new and its scenarios are still being tested. If a step behaves differently, tell the trainer.

**Goal:** Track down two faults you know nothing about, using the method of this course: scope first, then the layers on the client, then the evidence. This is the course's final case.

**Starting point:** You work in pairs, A and B, over two rounds. In each round, both of you draw a scenario card from the trainer:

| Round | Cards from | Object name | Time |
|---|---|---|---|
| 1 | Apps, scripts, remediations, configuration (Days 1–2) | `flaneX-Case1` | 25 min |
| 2 | Endpoint security, LAPS, EPM (Days 2–3) | `flaneX-Case2` | 25 min |

Each card describes one Intune object with exactly one wrong setting. You build it for your partner's CL3 while your partner builds one for yours. Keep your card to yourself.

**Exception for this lab:** you assign an object to your partner's device group – the only time in this course you touch another participant's group.

### Each round

1. Build the object exactly as your card describes, with this round's name (your own number), and assign it to your partner's `studentYdevices`.
2. Hand your partner only the helpdesk ticket from your card – not the settings.
3. Read the ticket you received and sync your CL3.
4. Start with scope: which objects reach CL3 now that didn't before?

   ```powershell
   PowerShell.exe -ExecutionPolicy Bypass -File C:\Toolbox\Get-IntunePolicyAssignmentsByGroup.ps1 -DeviceName CL3-yourname -ExportCsv
   ```

5. Find the cause on CL3 and in the Intune admin center – IME logs, registry, event log, `Get-MpPreference`, LAPS cycle, `Get-Policies`, Device query, whatever the object type calls for. Compare with what CL3 logged in your own labs.
6. Write down the root cause, the evidence (log line, event ID, registry value, cmdlet output or portal status) and the fix.
7. Check your result against your partner's card, then with the trainer.
8. Clean up by deleting your `flaneX-Case1` or `flaneX-Case2`.

### Checkpoint

- [ ] Round 1: root cause, evidence and fix named and confirmed by your partner's card
- [ ] Round 2: root cause, evidence and fix named and confirmed by your partner's card
- [ ] In both rounds, the toolbox device view revealed the new object
- [ ] `flaneX-Case1` and `flaneX-Case2` are deleted

<details markdown="1">
<summary>Hint 1 – where to start</summary>

Put the device view CSV next to the one from Exercise 13.2. The new row is your partner's object, and its type tells you which log to open. The log map is in the [Appendix](../Appendix.html#log-map).

</details>

<details markdown="1">
<summary>Hint 2 – compare with known-good</summary>

Open the same log for your own object from Exercise 5.1, 6.1, 11.1 or 12.1 and find the first line where your partner's object behaves differently.

</details>

<details markdown="1">
<summary>Hint 3 – conflict or wrong value?</summary>

Under Devices → `CL3-yourname` → Device configuration, **Conflict** means two policies set the same setting. **Succeeded** means the value arrived – so the value itself is wrong. Compare every setting of the object with your own working object: exactly one setting differs.

</details>

### Good to know

- **Timing:** your partner's object reaches CL3 like any other assignment – after a sync, an app within minutes.
- **Remediations and LAPS:** a remediation runs on its schedule; restart the IME if `HealthScripts.log` shows nothing after 5 minutes. For LAPS, run `Invoke-LapsPolicyProcessing` after the sync.

**Background:** In real life, nobody tells you the cause. You know what healthy looks like, and the first deviation shows you where to look.
