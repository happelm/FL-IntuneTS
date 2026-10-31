---
title: 'Lab 10.3 – Partner breaks, you fix: round 2'
lab:
    title: 'Lab 10.3 – Partner breaks, you fix: round 2'
    module: 'Day 3 – Advanced troubleshooting and scripting'
---

# Lab 10.3 – Partner breaks, you fix: round 2

**Estimated time:** 30 minutes

> **Draft:** This lab is new and its scenarios are still being tested. If a step behaves differently, tell the trainer.

**Goal:** Find a fault in an endpoint security, LAPS or EPM policy you do not know – and prove it with the client and with your toolbox.

**Starting point:** Same rules as in [Lab 10.2](LAB_10_2_partner-breaks-you-fix.html): you work in pairs, each of you draws a scenario card from the trainer, and you build the object for your partner's device. This time the cards cover the policy types of Labs 11.1 and 12.1.

**Exception for this lab:** You assign an object to your partner's device group. That is the only time in this course you touch another participant's group.

1. Build the object exactly as your card says. Name it `studentX-Case2` (your own number), assign it to your partner's `studentYdevices`.
2. Give your partner only the helpdesk ticket from your card.
3. Read the ticket you got and sync your CL3.
4. Start with the toolbox: which objects reach CL3 now that did not reach it this morning?

   ```powershell
   PowerShell.exe -ExecutionPolicy Bypass -File C:\Toolbox\Get-IntunePolicyAssignmentsByGroup.ps1 -DeviceName CL3-yourname -ExportCsv
   ```

5. Find the cause on CL3: event log, `Get-MpPreference`, `Get-Policies`, LAPS cycle, Device query – whatever the object type needs.
6. Write down the root cause, the evidence and the fix. Check your result with your partner's card, then with the trainer.
7. Clean up: delete your `studentX-Case2`.

### Checkpoint

- [ ] New object found with the toolbox script
- [ ] Root cause named, with the event ID, cmdlet output or Device query result as evidence
- [ ] Fix confirmed by your partner's card
- [ ] `studentX-Case2` deleted

<details markdown="1">
<summary>Hint 1 – where to start</summary>

Compare today's device view CSV with the one from Lab 13.1. The new row is your partner's object – its type tells you which log to open.

</details>

<details markdown="1">
<summary>Hint 2 – conflict or wrong value?</summary>

Devices → `CL3-yourname` → Device configuration: a **Conflict** status means two policies set the same setting. **Succeeded** means the value arrived – then the value itself is wrong.

</details>

**Why:** Day 3 adds tools, not a new method: scope first, then the layer on the client, then the evidence.
