# Trainer notes – Azure Files share and Microsoft Entra Kerberos

The lab files share `\\flane.file.core.windows.net\labfiles` serves CL3/CL4 in Labs 2.1 and 8.1. Participants sign in with their synced `flaneX` accounts and reach the share with a Kerberos ticket from Microsoft Entra ID.

**Before each course: nothing to do.** The share and its configuration stay in place between courses. Use this page only after a rebuild or when the share stops working.

## Setup checklist

### 1. DC1 – Microsoft Entra Kerberos server object

The pod domain `training.flane` needs the Microsoft Entra Kerberos server object for cloud Kerberos trust. Lab 8.1 and the DC1 demo use it for Windows Hello sign-in to on-premises resources. The Azure Files share itself doesn't need it: CL3/CL4 reach the share without line of sight to DC1.

On DC1, in an elevated PowerShell (module `AzureADHybridAuthenticationManagement`):

```powershell
Get-AzureADKerberosServer -Domain training.flane -UserPrincipalName <Global admin UPN> -DomainCredential (Get-Credential)
```

If no object is returned, create it with `Set-AzureADKerberosServer` and the same parameters. See [Create a Kerberos Server object](https://learn.microsoft.com/entra/identity/authentication/howto-authentication-passwordless-security-key-on-premises#create-a-kerberos-server-object).

### 2. Storage account – identity-based access

In the Azure portal, open the storage account and go to **File shares** > **Identity-based access**:

- Select **Microsoft Entra Kerberos**.
- Enter domain name `training.flane` and the domain GUID of `training.flane`. Get the GUID on DC1 with `(Get-ADDomain).ObjectGUID`.

### 3. Storage account app – admin consent

1. Go to Entra admin center > **App registrations** > **All applications**.
2. Open **[Storage Account] flane.file.core.windows.net** > **API permissions**.
3. Select **Grant admin consent** for openid, profile and User.Read.

### 4. Storage account app – cloud group SIDs

In the same app, open **Manifest**, add the tag to the `tags` array, then save:

```json
"tags": [
    "kdc_enable_cloud_group_sids"
]
```

If `tags` already holds values, keep them and add the tag to the list. Without the tag, the Kerberos ticket carries no cloud group SIDs, so permissions granted to cloud groups don't apply. See [Group SID limit in Entra Kerberos](https://learn.microsoft.com/entra/identity/authentication/kerberos#group-sid-limit-in-entra-kerberos-preview).

### 5. Conditional Access – exclude the storage app from MFA

Exclude **[Storage Account] flane.file.core.windows.net** from every Conditional Access policy that requires MFA. The ticket is requested silently during sign-in, without a prompt. See [Disable multifactor authentication on the storage account](https://learn.microsoft.com/azure/storage/files/storage-files-identity-auth-hybrid-identities-enable#disable-multifactor-authentication-on-the-storage-account).

### 6. Permissions

- **Share level (Azure RBAC):** **Storage File Data SMB Share Reader** on the share, assigned to the participant group **All StudentUsr Groups**.
- **Directory and file level (NTFS):** **Read & execute** on the share root for the same group. For hybrid identities, set NTFS permissions from a machine with line of sight to DC1, for example CL1 in the trainer pod.

### 7. Clients CL3/CL4

The tenant's Kerberos client policy `Kerberos/CloudKerberosTicketRetrievalEnabled` = 1 is assigned to the participant devices. It is the same policy as in Lab 8.1.

## Quick check

On CL3, signed in as a `flaneX` user:

```console
klist cloud_debug
klist get cifs/flane.file.core.windows.net
net use \\flane.file.core.windows.net\labfiles
```

`klist cloud_debug` must show a cloud TGT. After any change to the app, the tag, the groups or the policy, run `klist purge`, then sign out and sign in again before you test.

Reference: [Enable Microsoft Entra Kerberos authentication for hybrid and cloud-only identities on Azure Files](https://learn.microsoft.com/azure/storage/files/storage-files-identity-auth-hybrid-identities-enable)
