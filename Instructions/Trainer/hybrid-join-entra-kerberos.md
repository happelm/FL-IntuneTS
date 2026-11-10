# Trainer notes – Hybrid join and Microsoft Entra Kerberos (CL1/CL2 demo)

The trainer pod shows Microsoft Entra hybrid join and Windows Hello for Business cloud Kerberos trust on CL1 and CL2 in `training.flane`. Participants' CL3/CL4 are Microsoft Entra joined only; this setup is a trainer demo.

CL1 and CL2 join with **Microsoft Entra hybrid join using Microsoft Entra Kerberos (preview)**. The device gets its Entra ID object directly during the join, without AD FS and without Microsoft Entra Connect syncing the computer object. See [Microsoft Entra hybrid join using Microsoft Entra Kerberos](https://learn.microsoft.com/entra/identity/devices/how-to-hybrid-join-using-microsoft-entra-kerberos).

**Before each course: check only.** SCP, the Kerberos server object, the trusted domain object and the service principal settings stay in place. Use the checklist after a rebuild of the trainer pod.

## 1. Requirements

| Component | Requirement |
|---|---|
| Domain controller | At least one DC with Windows Server 2025 build 26100.6905 or later in `training.flane` |
| CL1, CL2 | Windows 11 build 26100.6584 or later, domain joined, line of sight to that DC during the join |
| AD account | Domain Admins and Enterprise Admins |
| Entra roles | Hybrid Identity Administrator (Kerberos objects), Application Administrator (service principal) |

Check the build with `winver` on DC1, CL1 and CL2.

## 2. Service connection point (SCP) on SRV1

Run [`ConfigureSCP.ps1`](https://github.com/happelm/FL-IntuneTS/tree/main/Labfiles/Trainer) on SRV1, signed in as Enterprise Admin. The script writes to AD over LDAP, so any domain member works. Use the tenant's `*.onmicrosoft.com` domain (no federation) and the tenant ID from Entra admin center → Overview.

```powershell
.\ConfigureSCP.ps1 -Domain <tenant>.onmicrosoft.com -TenantId <tenant ID>
```

The SCP is forest-wide: `CN=62a0ff2e-97b9-4513-943f-0d221bd30080` under `CN=Device Registration Configuration,CN=Services` in the configuration partition. Check it in ADSI Edit (Configuration partition) → attribute `keywords` holds `azureADName:` and `azureADId:`.

## 3. Microsoft Entra Kerberos server object and trusted domain object

Run sections 3 and 4 on SRV1, signed in as a Domain Admin and Enterprise Admin. In an elevated Windows PowerShell, install the module ([Learn](https://learn.microsoft.com/entra/identity/authentication/howto-authentication-passwordless-security-key-on-premises#install-the-azureadhybridauthenticationmanagement-module)):

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
Install-Module -Name AzureADHybridAuthenticationManagement -AllowClobber
```

Create the Kerberos server object and the trusted domain object in one step with `-SetupCloudTrust` ([Learn](https://learn.microsoft.com/azure/azure-sql/managed-instance/winauth-azuread-setup-incoming-trust-based-flow#create-and-configure-the-microsoft-entra-kerberos-trusted-domain-object)). If the Kerberos server object already exists, the same command adds only the trusted domain object. Use the UPN of a Hybrid Identity Administrator; sign in with MFA when prompted. The commands use your current domain sign-in, so `-DomainCredential` isn't needed.

```powershell
$domain     = 'training.flane'
$upn        = '<admin UPN>'
Set-AzureADKerberosServer -Domain $domain -UserPrincipalName $upn -SetupCloudTrust
Get-AzureADKerberosServer -Domain $domain -UserPrincipalName $upn
```

`Get-AzureADKerberosServer` shows the object with a `KeyVersion`, and `CloudTrustDisplay` shows `Microsoft.AzureAD.Kdc.Service.TrustDisplay`. An empty `CloudTrustDisplay` means the trusted domain object is missing. The same Kerberos server object serves Windows Hello for Business cloud Kerberos trust (section 6).

## 4. Device Registration Service principal

The Microsoft Entra Device Registration Service principal needs the SPN `adrs/enterpriseregistration.windows.net` and the tag `KerberosPolicy:ExchangeForJwt`. Use **PowerShell 7** (`pwsh`) for this step, not Windows PowerShell 5.1; Learn recommends PowerShell 7 for Microsoft Entra PowerShell.

If PowerShell 7 is missing on SRV1, install the MSI package ([Learn](https://learn.microsoft.com/powershell/scripting/install/install-powershell-on-windows)). On Windows Server 2025 with Desktop Experience, run in an elevated prompt:

```powershell
winget install --id Microsoft.PowerShell --source winget --installer-type wix
```

Without winget, download the current `PowerShell-7.x.x-win-x64.msi` from the Learn page and run it. Then open **PowerShell 7** as administrator and install [Microsoft Entra PowerShell](https://learn.microsoft.com/powershell/entra-powershell/installation):

```powershell
Install-Module -Name Microsoft.Entra -Repository PSGallery -Scope AllUsers -Force -AllowClobber
```

Then run the script from [Learn](https://learn.microsoft.com/entra/identity/devices/how-to-hybrid-join-using-microsoft-entra-kerberos#configure-microsoft-entra-device-registration-service-principal) and sign in as Application Administrator. It adds only what is missing and shows the result.

Open a new PowerShell 7 window first. The script signs in with `Connect-MgGraph` instead of `Connect-Entra`: `Connect-Entra` in Microsoft.Entra 1.3.0 fails with a known bug ([entra-powershell #1614](https://github.com/microsoftgraph/entra-powershell/issues/1614)). `Connect-Entra` is a wrapper for `Connect-MgGraph`, and the Entra cmdlets use the same session.

```powershell
Connect-MgGraph -Scopes 'Application.ReadWrite.All'

$drsSP = Get-EntraServicePrincipal -Filter "AppId eq '01cb2876-7ebd-4aa4-9cc9-d28bd4d359a9'"

$needsUpdate = $false
$spns = [System.Collections.Generic.List[string]]::new($drsSP.ServicePrincipalNames)
$tags = [System.Collections.Generic.List[string]]::new($drsSP.Tags)

$kerbSpn = 'adrs/enterpriseregistration.windows.net'
if ($drsSP.ServicePrincipalNames -notcontains $kerbSpn) {
    Write-Host 'Kerberos SPN needs to be added'
    $spns.Add($kerbSpn)
    $needsUpdate = $true
}

$kerberosTag = 'KerberosPolicy:ExchangeForJwt'
if ($drsSP.Tags -notcontains $kerberosTag) {
    Write-Host 'Kerberos policy tag needs to be added'
    $tags.Add($kerberosTag)
    $needsUpdate = $true
}

if ($needsUpdate) {
    Set-EntraServicePrincipal -ObjectId $drsSP.Id -ServicePrincipalNames $spns -Tags $tags
    Write-Host 'Service principal configuration updated'
} else {
    Write-Host 'Service principal already configured'
}

$drsSP = Get-EntraServicePrincipal -Filter "AppId eq '01cb2876-7ebd-4aa4-9cc9-d28bd4d359a9'"
$drsSP.ServicePrincipalNames
$drsSP.Tags
```

**KDC proxy GPO:** only needed if CL1/CL2 already get the policy **Administrative Templates\System\Kerberos\Specify KDC proxy servers for Kerberos clients**. In that case add the mapping from [Learn](https://learn.microsoft.com/entra/identity/devices/how-to-hybrid-join-using-microsoft-entra-kerberos#configure-the-kdc-proxy-server-gpo). Otherwise skip it.

## 5. Hybrid join CL1 and CL2

CL1 and CL2 are domain joined. After a restart, the join runs on its own. To start it right away, run in an elevated prompt:

```powershell
Start-ScheduledTask -TaskPath '\Microsoft\Windows\Workplace Join\' -TaskName 'Automatic-Device-Join'
```

Or run `dsregcmd /join`. The device appears in Entra ID right after the join; the computer OU doesn't need to be in the sync scope. Check with `dsregcmd /status`: `AzureAdJoined : YES` and `DomainJoined : YES`. Sign out and in again, then `AzureAdPrt : YES`.

## 6. Windows Hello for Business with cloud Kerberos trust

Two settings are required, a third is recommended ([Learn](https://learn.microsoft.com/windows/security/identity-protection/hello-for-business/deploy/hybrid-cloud-kerberos-trust#configure-windows-hello-for-business-policy-settings)). Deliver them with **one** of the two sources:

- **Intune** (Settings catalog, devices or users of CL1/CL2): only if CL1/CL2 are enrolled in Intune.
- **GPO** on DC1 (Computer Configuration\Administrative Templates\Windows Components\Windows Hello for Business): cloud Kerberos trust exists only as a computer setting. If the setting is missing, copy `Passport.admx`/`Passport.adml` from a current Windows 11 client to the central store.

| Setting (Intune / GPO) | Value |
|---|---|
| Use Windows Hello For Business / Use Windows Hello for Business | true / Enabled |
| Use Cloud Trust For On Prem Auth / Use cloud Kerberos trust for on-premises authentication | Enabled |
| Require Security Device / Use a hardware security device | true / Enabled |

- Group Policy wins over Intune for Windows Hello. If both deliver settings, Intune is ignored.
- CL1/CL2 must not get **Use certificate for on-premises authentication**.
- Use a `flaneX` user. Members of privileged built-in groups (for example Domain Admins) can't use cloud Kerberos trust.
- The user sets up the PIN with MFA. The first PIN sign-in needs line of sight to DC1.

## Quick check

On CL1, signed in with a Windows Hello PIN as a `flaneX` user:

```console
dsregcmd /status
klist cloud_debug
dir \\dc1\labfiles
```

`dsregcmd /status` shows `CloudTgt : YES` and `OnPremTgt : YES`; access to `\\dc1\labfiles` works without a prompt.
