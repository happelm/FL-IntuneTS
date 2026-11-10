# Trainer notes – Hybrid join and Microsoft Entra Kerberos (CL1/CL2 demo)

The trainer pod shows Microsoft Entra hybrid join and Windows Hello for Business cloud Kerberos trust on CL1 and CL2 in `training.flane`. Participants' CL3/CL4 are Microsoft Entra joined only; this setup is a trainer demo.

**Before each course: check only.** SCP, sync scope and the Kerberos server object stay in place. Use the checklist after a rebuild of the trainer pod.

## 1. Service connection point (SCP) on DC1

Run [`ConfigureSCP.ps1`](https://github.com/happelm/FL-IntuneTS/tree/main/Labfiles/Trainer) on DC1 as Enterprise Admin. Use the tenant's `*.onmicrosoft.com` domain (no federation) and the tenant ID from Entra admin center → Overview.

```powershell
.\ConfigureSCP.ps1 -Domain <tenant>.onmicrosoft.com -TenantId <tenant ID>
```

The SCP is forest-wide: `CN=62a0ff2e-97b9-4513-943f-0d221bd30080` under `CN=Device Registration Configuration,CN=Services` in the configuration partition. Check it in ADSI Edit (Configuration partition) → attribute `keywords` holds `azureADName:` and `azureADId:`.

## 2. Sync scope

The sync from DC1 must include the OU of the computer objects CL1 and CL2, not only the user OU.

## 3. Hybrid join CL1 and CL2

On CL1 and CL2, start the join task (or run `dsregcmd /join` in an elevated prompt):

```powershell
Start-ScheduledTask -TaskPath '\Microsoft\Windows\Workplace Join\' -TaskName 'Automatic-Device-Join'
```

The first run writes `userCertificate` on the computer object; the sync then creates the device in Entra ID. Start the task a second time once the device is in Entra ID. Check with `dsregcmd /status`: `AzureAdJoined : YES` and `DomainJoined : YES`. Sign out and in again, then `AzureAdPrt : YES`.

## 4. Microsoft Entra Kerberos server object

On DC1 (or the sync server), elevated Windows PowerShell. Install the module ([Learn](https://learn.microsoft.com/entra/identity/authentication/howto-authentication-passwordless-security-key-on-premises#install-the-azureadhybridauthenticationmanagement-module)):

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
Install-Module -Name AzureADHybridAuthenticationManagement -AllowClobber
```

Create the object and check it ([Learn](https://learn.microsoft.com/entra/identity/authentication/howto-authentication-passwordless-security-key-on-premises#create-a-kerberos-server-object)). Use the UPN of a Hybrid Identity Administrator or Global Administrator; sign in with MFA when prompted. For the domain credential, enter the domain admin in UPN format.

```powershell
$domain = 'training.flane'
$upn    = '<admin UPN>'
Set-AzureADKerberosServer -Domain $domain -UserPrincipalName $upn -DomainCredential (Get-Credential)
Get-AzureADKerberosServer -Domain $domain -UserPrincipalName $upn -DomainCredential (Get-Credential)
```

`Get-AzureADKerberosServer` shows the object with a `KeyVersion`. An empty result means it is not configured.

## 5. Windows Hello for Business with cloud Kerberos trust

Settings catalog policy for the devices or users of CL1/CL2 ([Learn](https://learn.microsoft.com/windows/security/identity-protection/hello-for-business/deploy/hybrid-cloud-kerberos-trust#configure-windows-hello-for-business-policy-settings)):

| Setting | Value |
|---|---|
| Windows Hello for Business → Use Windows Hello For Business | true |
| Windows Hello for Business → Use Cloud Trust For On Prem Auth | Enabled |
| Windows Hello for Business → Require Security Device | true |

CL1/CL2 must not get **Use certificate for on-premises authentication**, and no Windows Hello GPO from DC1 – Group Policy wins over Intune for Windows Hello.

## Quick check

On CL1, signed in with a Windows Hello PIN as a `flaneX` user:

```console
dsregcmd /status
klist cloud_debug
dir \\dc1\labfiles
```

`dsregcmd /status` shows `CloudTgt : YES` and `OnPremTgt : YES`; access to `\\dc1\labfiles` works without a prompt.
