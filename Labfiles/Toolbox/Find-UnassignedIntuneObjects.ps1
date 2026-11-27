<#
.SYNOPSIS
    Lists Intune objects that reach nobody: unassigned, exclusions only, or assigned only to deleted groups.

.DESCRIPTION
    In the Intune admin center you see assignments per object and per object type, which makes
    forgotten objects easy to miss. This script reads every supported object type and reports each
    object with one of these findings:
      Unassigned       : the object has no assignment
      ExcludeOnly      : the object has exclusions but no include
      DeletedGroupsOnly: every include points to a group that no longer exists in Entra ID
      SomeDeletedGroups: at least one include or exclusion points to a deleted group
                         (the object still applies through its other assignments)

    The ScopeTags column tells you which Intune admins can see and edit a finding - useful for an
    RBAC review.

    The script only reads (GET, plus POST $batch that carries GET requests). Nothing in the tenant
    changes. Default objects that apply without an assignment (default enrollment configurations,
    the default Company Portal branding profile) are left out.

.PARAMETER Category
    Limit the object types: Configuration, Compliance, Scripts, Updates, Apps, Enrollment or All
    (default). Several values are allowed.

.PARAMETER Status
    Limit the findings: Unassigned, ExcludeOnly, DeletedGroupsOnly, SomeDeletedGroups. Default: all.

.PARAMETER ExportCsv
    Write the result as CSV (delimiter ';', UTF-8) to -OutputFolder.

.PARAMETER OutputFolder
    Target folder for the CSV file. Default: the current folder.

.PARAMETER SkipTenantConfirmation
    Skip the question that confirms the connected tenant.

.PARAMETER PassThru
    Also return the result objects to the pipeline.

.EXAMPLE
    .\Find-UnassignedIntuneObjects.ps1

.EXAMPLE
    .\Find-UnassignedIntuneObjects.ps1 -Category Configuration,Compliance -Status Unassigned -ExportCsv

.EXAMPLE
    $r = .\Find-UnassignedIntuneObjects.ps1 -PassThru -SkipTenantConfirmation
    $r | Where-Object ScopeTags -eq 'Default' | Format-Table ObjectType, Name

.NOTES
    Intune-TS lab toolbox - read-only.
    Needs   : Microsoft.Graph.Authentication 2.x (Invoke-MgGraphRequest with -SkipHttpErrorCheck),
              Windows PowerShell 5.1 or PowerShell 7
    Scopes  : DeviceManagementConfiguration.Read.All, DeviceManagementApps.Read.All,
              DeviceManagementScripts.Read.All, DeviceManagementServiceConfig.Read.All,
              DeviceManagementRBAC.Read.All, GroupMember.Read.All
    Uses the same object catalog and Graph helpers as Get-IntunePolicyAssignmentsByGroup.ps1.
    Your Intune role still filters the result: Graph returns no objects outside your scope tags.
#>

[CmdletBinding()]
param(
    [ValidateSet('All', 'Configuration', 'Compliance', 'Scripts', 'Updates', 'Apps', 'Enrollment')]
    [string[]]$Category = @('All'),

    [ValidateSet('Unassigned', 'ExcludeOnly', 'DeletedGroupsOnly', 'SomeDeletedGroups')]
    [string[]]$Status = @('Unassigned', 'ExcludeOnly', 'DeletedGroupsOnly', 'SomeDeletedGroups'),

    [switch]$ExportCsv,

    [string]$OutputFolder = (Get-Location).Path,

    [switch]$SkipTenantConfirmation,

    [switch]$PassThru
)

$ErrorActionPreference = 'Stop'
$GraphBeta = 'https://graph.microsoft.com/beta'
$GraphV1 = 'https://graph.microsoft.com/v1.0'

$RequiredScopes = @(
    'DeviceManagementConfiguration.Read.All',
    'DeviceManagementApps.Read.All',
    'DeviceManagementScripts.Read.All',
    'DeviceManagementServiceConfig.Read.All',
    'DeviceManagementRBAC.Read.All',
    'GroupMember.Read.All'
)

#region Graph module and sign-in
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Authentication)) {
    Write-Host 'Installing Microsoft.Graph.Authentication (CurrentUser)...' -ForegroundColor Yellow
    Install-Module Microsoft.Graph.Authentication -Scope CurrentUser -Force
}
Import-Module Microsoft.Graph.Authentication

$cmd = Get-Command Invoke-MgGraphRequest
if (-not $cmd.Parameters.ContainsKey('SkipHttpErrorCheck') -or -not $cmd.Parameters.ContainsKey('StatusCodeVariable')) {
    throw 'Invoke-MgGraphRequest is too old (no -SkipHttpErrorCheck / -StatusCodeVariable). Run: Update-Module Microsoft.Graph.Authentication'
}

$context = Get-MgContext
$missingScopes = @()
if ($context) { $missingScopes = @($RequiredScopes | Where-Object { $context.Scopes -notcontains $_ }) }
if (-not $context -or $missingScopes.Count -gt 0) {
    if ($context) { Write-Host "Reconnecting, missing scopes: $($missingScopes -join ', ')" -ForegroundColor Yellow }
    Connect-MgGraph -Scopes $RequiredScopes -NoWelcome
    $context = Get-MgContext
}
Write-Host "Connected as $($context.Account) to tenant $($context.TenantId)" -ForegroundColor Green
if (-not $SkipTenantConfirmation) {
    $answer = Read-Host 'Is this the right tenant? [y/N]'
    if ($answer -notmatch '^(y|yes|j|ja)$') { Write-Host 'Aborted.' -ForegroundColor Yellow; return }
}
#endregion

#region Graph request helpers
function Invoke-Graph {
    # Sends GET or POST, evaluates the status code and retries on 429, 503 and 504.
    # The Graph SDK has its own retry for throttling; this loop handles whatever is still failing after it.
    param(
        [string]$Uri,
        [string]$Method = 'GET',
        [string]$Body,
        [int]$MaxRetries = 4
    )
    for ($attempt = 0; $attempt -le $MaxRetries; $attempt++) {
        $sc = $null; $rh = $null
        $p = @{
            Method                  = $Method
            Uri                     = $Uri
            OutputType              = 'HashTable'
            SkipHttpErrorCheck      = $true
            StatusCodeVariable      = 'sc'
            ResponseHeadersVariable = 'rh'
        }
        if ($Body) { $p.Body = $Body; $p.ContentType = 'application/json' }
        $resp = Invoke-MgGraphRequest @p
        $status = [int]$sc
        if (($status -in @(429, 503, 504)) -and ($attempt -lt $MaxRetries)) {
            $wait = [math]::Pow(2, $attempt + 1) * 5
            if ($rh -and $rh['Retry-After']) {
                $ra = @($rh['Retry-After'])[0]
                $sec = 0
                if ([int]::TryParse("$ra", [ref]$sec)) { $wait = $sec }
            }
            Write-Host "    HTTP $status - waiting $wait s (retry $($attempt + 1)/$MaxRetries)" -ForegroundColor DarkYellow
            Start-Sleep -Seconds $wait
            continue
        }
        $msg = $null
        if ($status -ge 400 -and $resp -and $resp.error) { $msg = $resp.error.message }
        return @{ Status = $status; Body = $resp; Message = $msg }
    }
}

function Get-GraphCollection {
    # Pages through @odata.nextLink and returns Status, Items and Message.
    param([string]$Uri)
    $items = New-Object System.Collections.Generic.List[object]
    $next = $Uri
    while ($next) {
        $r = Invoke-Graph -Uri $next
        if ($r.Status -ne 200) { return @{ Status = $r.Status; Items = $items; Message = $r.Message } }
        foreach ($v in @($r.Body.value)) { if ($null -ne $v) { $items.Add($v) } }
        $next = $r.Body.'@odata.nextLink'
    }
    return @{ Status = 200; Items = $items; Message = $null }
}

function Invoke-GraphBatchGet {
    # Reads many relative URLs through JSON batching, 20 requests per batch. Throttled requests inside a
    # batch are retried here - the retry handlers of the SDK don't look inside a batch.
    # Result: hashtable url -> @{ Status; Body }
    param([string[]]$RelativeUrls, [string]$BaseUri = $GraphBeta)
    $results = @{}
    $pending = New-Object System.Collections.Generic.List[string]
    foreach ($u in $RelativeUrls) { $pending.Add($u) }
    $round = 0
    while ($pending.Count -gt 0 -and $round -lt 5) {
        $round++
        $retry = New-Object System.Collections.Generic.List[string]
        $maxWait = 0
        $pendingArr = $pending.ToArray()
        for ($i = 0; $i -lt $pendingArr.Count; $i += 20) {
            $chunk = @($pendingArr[$i..([math]::Min($i + 19, $pendingArr.Count - 1))])
            $requests = @()
            for ($j = 0; $j -lt $chunk.Count; $j++) { $requests += @{ id = "$j"; method = 'GET'; url = $chunk[$j] } }
            $body = @{ requests = $requests } | ConvertTo-Json -Depth 5
            $r = Invoke-Graph -Uri "$BaseUri/`$batch" -Method POST -Body $body
            if ($r.Status -ne 200) {
                foreach ($u in $chunk) { $results[$u] = @{ Status = $r.Status; Body = $null } }
                continue
            }
            foreach ($sub in @($r.Body.responses)) {
                $url = $chunk[[int]$sub.id]
                if ([int]$sub.status -eq 429) {
                    $retry.Add($url)
                    $ra = 10
                    if ($sub.headers -and $sub.headers['Retry-After']) { [void][int]::TryParse("$($sub.headers['Retry-After'])", [ref]$ra) }
                    if ($ra -gt $maxWait) { $maxWait = $ra }
                }
                else {
                    $results[$url] = @{ Status = [int]$sub.status; Body = $sub.body }
                }
            }
        }
        $pending = $retry
        if ($pending.Count -gt 0) {
            Write-Host "    Batch: $($pending.Count) throttled sub-requests, waiting $maxWait s" -ForegroundColor DarkYellow
            Start-Sleep -Seconds $maxWait
        }
    }
    foreach ($u in $pending) { $results[$u] = @{ Status = 429; Body = $null } }
    return $results
}

function Get-ShortType([string]$ODataType) {
    if (-not $ODataType) { return $null }
    return ($ODataType -replace '^#microsoft\.graph\.', '')
}
#endregion

#region Name lookups: assignment filters, scope tags, policy sets
Write-Host "`nLoading lookups..." -ForegroundColor Cyan
$filterLookup = @{}
$r = Get-GraphCollection -Uri "$GraphBeta/deviceManagement/assignmentFilters?`$select=id,displayName,platform"
foreach ($f in $r.Items) { $filterLookup[$f.id] = $f.displayName }
Write-Host "  Assignment filters: $($filterLookup.Count)" -ForegroundColor Gray

$scopeTagLookup = @{}
$scopeTagResult = Get-GraphCollection -Uri "$GraphBeta/deviceManagement/roleScopeTags?`$select=id,displayName"
foreach ($t in $scopeTagResult.Items) { $scopeTagLookup["$($t.id)"] = $t.displayName }
Write-Host "  Scope tags: $($scopeTagLookup.Count)" -ForegroundColor Gray

$policySetLookup = @{}
$policySetResult = Get-GraphCollection -Uri "$GraphBeta/deviceAppManagement/policySets?`$select=id,displayName"
foreach ($ps in $policySetResult.Items) { $policySetLookup[$ps.id] = $ps.displayName }
Write-Host "  Policy sets: $($policySetLookup.Count)" -ForegroundColor Gray
#endregion

#region Object types that are read
# Path   : collection below /beta
# Name   : property that holds the display name
# Select : extra properties next to id and name (left out automatically if the endpoint refuses them)
# Expand : $true where $expand=assignments works (checked 2026-10-19); otherwise assignments come via $batch
# Filter : optional $filter
$catalog = @(
    @{ Cat = 'Configuration'; Label = 'Device configuration';           Path = '/deviceManagement/deviceConfigurations';           Name = 'displayName'; Select = 'roleScopeTagIds'; Expand = $true }
    @{ Cat = 'Configuration'; Label = 'Settings catalog';               Path = '/deviceManagement/configurationPolicies';          Name = 'name';        Select = 'roleScopeTagIds,platforms,technologies,templateReference'; Expand = $true; Template = $true }
    @{ Cat = 'Configuration'; Label = 'Administrative templates';       Path = '/deviceManagement/groupPolicyConfigurations';      Name = 'displayName'; Select = 'roleScopeTagIds'; Expand = $true }
    @{ Cat = 'Configuration'; Label = 'Endpoint security (legacy intent)'; Path = '/deviceManagement/intents';                    Name = 'displayName'; Select = 'roleScopeTagIds,templateId'; Expand = $true }
    @{ Cat = 'Configuration'; Label = 'BIOS configuration';             Path = '/deviceManagement/hardwareConfigurations';         Name = 'displayName'; Select = 'roleScopeTagIds'; Expand = $true }
    @{ Cat = 'Compliance';    Label = 'Compliance policy';              Path = '/deviceManagement/deviceCompliancePolicies';       Name = 'displayName'; Select = 'roleScopeTagIds'; Expand = $true }
    @{ Cat = 'Compliance';    Label = 'Compliance (settings catalog)';  Path = '/deviceManagement/compliancePolicies';             Name = 'name';        Select = 'roleScopeTagIds,platforms'; Expand = $true }
    @{ Cat = 'Scripts';       Label = 'Platform script (Windows)';      Path = '/deviceManagement/deviceManagementScripts';        Name = 'displayName'; Select = 'roleScopeTagIds,runAsAccount'; Expand = $true }
    @{ Cat = 'Scripts';       Label = 'Remediation';                    Path = '/deviceManagement/deviceHealthScripts';            Name = 'displayName'; Select = 'roleScopeTagIds,isGlobalScript'; Expand = $true }
    @{ Cat = 'Scripts';       Label = 'Shell script (macOS)';           Path = '/deviceManagement/deviceShellScripts';             Name = 'displayName'; Select = 'roleScopeTagIds'; Expand = $true }
    @{ Cat = 'Scripts';       Label = 'Custom attribute (macOS)';       Path = '/deviceManagement/deviceCustomAttributeShellScripts'; Name = 'displayName'; Select = 'roleScopeTagIds'; Expand = $true }
    @{ Cat = 'Updates';       Label = 'Feature update (Windows)';       Path = '/deviceManagement/windowsFeatureUpdateProfiles';   Name = 'displayName'; Select = 'roleScopeTagIds,featureUpdateVersion'; Expand = $true }
    @{ Cat = 'Updates';       Label = 'Quality update expedite (Windows)'; Path = '/deviceManagement/windowsQualityUpdateProfiles'; Name = 'displayName'; Select = 'roleScopeTagIds'; Expand = $true }
    @{ Cat = 'Updates';       Label = 'Quality update policy (Windows)'; Path = '/deviceManagement/windowsQualityUpdatePolicies';  Name = 'displayName'; Select = 'roleScopeTagIds,hotpatchEnabled'; Expand = $true }
    @{ Cat = 'Updates';       Label = 'Driver update (Windows)';        Path = '/deviceManagement/windowsDriverUpdateProfiles';    Name = 'displayName'; Select = 'roleScopeTagIds,approvalType'; Expand = $true }
    @{ Cat = 'Apps';          Label = 'App';                            Path = '/deviceAppManagement/mobileApps';                  Name = 'displayName'; Select = 'roleScopeTagIds,publisher'; Expand = $true }
    @{ Cat = 'Apps';          Label = 'App configuration (managed devices)'; Path = '/deviceAppManagement/mobileAppConfigurations'; Name = 'displayName'; Select = 'roleScopeTagIds'; Expand = $true }
    @{ Cat = 'Apps';          Label = 'App configuration (managed apps)'; Path = '/deviceAppManagement/targetedManagedAppConfigurations'; Name = 'displayName'; Select = 'roleScopeTagIds'; Expand = $true }
    @{ Cat = 'Apps';          Label = 'App protection (iOS)';           Path = '/deviceAppManagement/iosManagedAppProtections';    Name = 'displayName'; Select = 'roleScopeTagIds'; Expand = $true }
    @{ Cat = 'Apps';          Label = 'App protection (Android)';       Path = '/deviceAppManagement/androidManagedAppProtections'; Name = 'displayName'; Select = 'roleScopeTagIds'; Expand = $true }
    @{ Cat = 'Apps';          Label = 'App protection (Windows)';       Path = '/deviceAppManagement/windowsManagedAppProtections'; Name = 'displayName'; Select = 'roleScopeTagIds'; Expand = $true }
    @{ Cat = 'Apps';          Label = 'Policy set';                     Path = '/deviceAppManagement/policySets';                  Name = 'displayName'; Select = '';                Expand = $false }
    @{ Cat = 'Enrollment';    Label = 'Enrollment configuration';       Path = '/deviceManagement/deviceEnrollmentConfigurations'; Name = 'displayName'; Select = 'roleScopeTagIds,priority'; Expand = $true }
    @{ Cat = 'Enrollment';    Label = 'Autopilot deployment profile';   Path = '/deviceManagement/windowsAutopilotDeploymentProfiles'; Name = 'displayName'; Select = 'roleScopeTagIds'; Expand = $true }
    @{ Cat = 'Enrollment';    Label = 'Apple user-initiated enrollment'; Path = '/deviceManagement/appleUserInitiatedEnrollmentProfiles'; Name = 'displayName'; Select = 'priority'; Expand = $true }
    @{ Cat = 'Enrollment';    Label = 'Terms and conditions';           Path = '/deviceManagement/termsAndConditions';             Name = 'displayName'; Select = 'roleScopeTagIds'; Expand = $false }
    @{ Cat = 'Enrollment';    Label = 'Company Portal branding';        Path = '/deviceManagement/intuneBrandingProfiles';         Name = 'profileName'; Select = 'roleScopeTagIds,isDefaultProfile'; Expand = $true }
)

$templateFamilyLabel = @{
    'none'                                         = 'Settings catalog'
    'endpointSecurityAntivirus'                    = 'Endpoint security - Antivirus'
    'endpointSecurityDiskEncryption'               = 'Endpoint security - Disk encryption'
    'endpointSecurityFirewall'                     = 'Endpoint security - Firewall'
    'endpointSecurityEndpointDetectionAndResponse' = 'Endpoint security - EDR'
    'endpointSecurityAttackSurfaceReduction'       = 'Endpoint security - ASR'
    'endpointSecurityAccountProtection'            = 'Endpoint security - Account protection'
    'endpointSecurityApplicationControl'           = 'Endpoint security - App Control'
    'endpointSecurityEndpointPrivilegeManagement'  = 'Endpoint security - EPM'
    'enrollmentConfiguration'                      = 'Enrollment configuration'
    'appQuietTime'                                 = 'App quiet time'
    'baseline'                                     = 'Security baseline'
    'deviceConfigurationScripts'                   = 'Device configuration script'
    'deviceConfigurationPolicies'                  = 'Device configuration policy'
    'windowsOsRecoveryPolicies'                    = 'Windows OS recovery'
    'companyPortal'                                = 'Company Portal'
}

$enrollmentTypeLabel = @{
    'windows10EnrollmentCompletionPageConfiguration'          = 'Enrollment Status Page'
    'deviceEnrollmentPlatformRestrictionsConfiguration'       = 'Platform restrictions (default)'
    'deviceEnrollmentPlatformRestrictionConfiguration'        = 'Platform restriction'
    'deviceEnrollmentLimitConfiguration'                      = 'Device limit'
    'deviceEnrollmentWindowsHelloForBusinessConfiguration'    = 'Windows Hello for Business'
    'windowsRestoreDeviceEnrollmentConfiguration'             = 'Windows Backup and Restore'
    'deviceComanagementAuthorityConfiguration'                = 'Co-management settings'
    'deviceEnrollmentNotificationConfiguration'               = 'Enrollment notification'
}

$selected = $catalog
if ($Category -notcontains 'All') { $selected = @($catalog | Where-Object { $Category -contains $_.Cat }) }
#endregion

function Get-ObjectTypeLabel($def, $obj) {
    $odataType = Get-ShortType $obj.'@odata.type'
    if ($def.Template -and $obj.templateReference) {
        $fam = "$($obj.templateReference.templateFamily)"
        $lbl = $templateFamilyLabel[$fam]
        if (-not $lbl) { $lbl = $fam }
        if ($fam -ne 'none' -and $obj.templateReference.templateDisplayName) { $lbl = "$lbl ($($obj.templateReference.templateDisplayName))" }
        return $lbl
    }
    if ($def.Path -like '*deviceEnrollmentConfigurations' -and $odataType) {
        $lbl = $enrollmentTypeLabel[$odataType]
        if ($lbl) { return "Enrollment - $lbl" }
        return "Enrollment - $odataType"
    }
    if ($odataType -and $def.Path -match 'deviceConfigurations|mobileApps|mobileAppConfigurations|windowsAutopilotDeploymentProfiles|deviceCompliancePolicies') {
        return "$($def.Label) ($odataType)"
    }
    return $def.Label
}

function Test-ImplicitDefault($def, $obj) {
    # Default objects that apply even without an assignment
    if ($def.Path -like '*deviceEnrollmentConfigurations' -and "$($obj.priority)" -eq '0') { return $true }
    if ($def.Path -like '*intuneBrandingProfiles' -and $obj.isDefaultProfile) { return $true }
    return $false
}

#region Read objects and assignments
$found = New-Object System.Collections.Generic.List[object]   # objects with their assignments
$skipped = New-Object System.Collections.Generic.List[object]

Write-Host "`nQuerying Intune objects..." -ForegroundColor Cyan
foreach ($def in $selected) {
    $baseSelect = "id,$($def.Name)"
    $qs = @()
    if ($def.Select) { $qs += "`$select=$baseSelect,$($def.Select)" } else { $qs += "`$select=$baseSelect" }
    if ($def.Expand) { $qs += '$expand=assignments' }
    if ($def.Filter) { $qs += "`$filter=$([uri]::EscapeDataString($def.Filter))" }

    $r = Get-GraphCollection -Uri ("$GraphBeta$($def.Path)?" + ($qs -join '&'))
    if ($r.Status -eq 400 -and $def.Select) {
        $qs[0] = "`$select=$baseSelect"
        $r = Get-GraphCollection -Uri ("$GraphBeta$($def.Path)?" + ($qs -join '&'))
    }
    $needBatch = -not $def.Expand
    if ($r.Status -eq 400 -and $def.Expand) {
        $qs = @($qs | Where-Object { $_ -ne '$expand=assignments' })
        $r = Get-GraphCollection -Uri ("$GraphBeta$($def.Path)?" + ($qs -join '&'))
        $needBatch = $true
    }
    if ($r.Status -ne 200) {
        $reason = switch ($r.Status) { 403 { 'Forbidden (Graph scope or Intune RBAC)' } 404 { 'Endpoint not found' } default { "HTTP $($r.Status)" } }
        $skipped.Add([PSCustomObject]@{ ObjectType = $def.Label; Reason = $reason; Message = $r.Message })
        Write-Host ("  {0,-40} skipped: {1}" -f $def.Label, $reason) -ForegroundColor DarkYellow
        continue
    }

    $objects = @($r.Items | Where-Object { -not (Test-ImplicitDefault $def $_) })
    if ($needBatch -and $objects.Count -gt 0) {
        $urls = @($objects | ForEach-Object { "$($def.Path)/$($_.id)/assignments" })
        $batch = Invoke-GraphBatchGet -RelativeUrls $urls
        foreach ($o in $objects) {
            $br = $batch["$($def.Path)/$($o.id)/assignments"]
            if ($br -and $br.Status -eq 200) { $found.Add(@{ Def = $def; Obj = $o; Assignments = @($br.Body.value) }) }
            else { $skipped.Add([PSCustomObject]@{ ObjectType = $def.Label; Reason = "Assignments of '$($o.($def.Name))': HTTP $($br.Status)"; Message = $null }) }
        }
    }
    else {
        foreach ($o in $objects) { $found.Add(@{ Def = $def; Obj = $o; Assignments = @($o.assignments) }) }
    }
    Write-Host ("  {0,-40} {1,5} objects" -f $def.Label, $objects.Count) -ForegroundColor Gray
}
#endregion

#region Groups that no longer exist
# Gather every group ID used in an assignment and check which of them still exist
$groupIds = @{}
foreach ($f in $found) {
    foreach ($a in $f.Assignments) {
        if ($a -and $a.target -and $a.target.groupId) { $groupIds[$a.target.groupId] = $true }
    }
}
$deletedGroups = @{}
$groupNames = @{}
if ($groupIds.Count -gt 0) {
    Write-Host "`nChecking $($groupIds.Count) assigned groups..." -ForegroundColor Cyan
    $urls = @($groupIds.Keys | ForEach-Object { "/groups/$_`?`$select=id,displayName" })
    $batch = Invoke-GraphBatchGet -RelativeUrls $urls -BaseUri $GraphV1
    foreach ($id in $groupIds.Keys) {
        $br = $batch["/groups/$id`?`$select=id,displayName"]
        if ($br.Status -eq 200) { $groupNames[$id] = $br.Body.displayName }
        elseif ($br.Status -eq 404) { $deletedGroups[$id] = $true }
        else { Write-Host "  Group $id could not be checked (HTTP $($br.Status))" -ForegroundColor DarkYellow }
    }
    Write-Host "  Deleted groups still referenced: $($deletedGroups.Count)" -ForegroundColor Gray
}
#endregion

#region Classify the findings
$results = New-Object System.Collections.Generic.List[object]
foreach ($f in $found) {
    $def = $f.Def; $obj = $f.Obj
    $assignments = @($f.Assignments | Where-Object { $_ -and $_.target })
    $includes = @($assignments | Where-Object { (Get-ShortType $_.target.'@odata.type') -ne 'exclusionGroupAssignmentTarget' })
    $excludes = @($assignments | Where-Object { (Get-ShortType $_.target.'@odata.type') -eq 'exclusionGroupAssignmentTarget' })
    $deletedRefs = @($assignments | Where-Object { $_.target.groupId -and $deletedGroups.ContainsKey($_.target.groupId) })
    $liveIncludes = @($includes | Where-Object { -not ($_.target.groupId -and $deletedGroups.ContainsKey($_.target.groupId)) })

    $state = $null
    if ($assignments.Count -eq 0) { $state = 'Unassigned' }
    elseif ($includes.Count -eq 0) { $state = 'ExcludeOnly' }
    elseif ($liveIncludes.Count -eq 0) { $state = 'DeletedGroupsOnly' }
    elseif ($deletedRefs.Count -gt 0) { $state = 'SomeDeletedGroups' }
    if (-not $state -or $Status -notcontains $state) { continue }

    $tags = $null
    if ($obj.roleScopeTagIds) {
        $tags = (@($obj.roleScopeTagIds) | ForEach-Object { $n = $scopeTagLookup["$_"]; if ($n) { $n } else { $_ } }) -join ', '
    }
    $targets = @($assignments | ForEach-Object {
            $tt = Get-ShortType $_.target.'@odata.type'
            $g = $_.target.groupId
            $label = switch ($tt) {
                'groupAssignmentTarget'            { 'Include' }
                'exclusionGroupAssignmentTarget'   { 'Exclude' }
                'allLicensedUsersAssignmentTarget' { 'All users' }
                'allDevicesAssignmentTarget'       { 'All devices' }
                default                            { $tt }
            }
            if ($g) {
                $gn = if ($deletedGroups.ContainsKey($g)) { "DELETED $g" } elseif ($groupNames[$g]) { $groupNames[$g] } else { $g }
                "${label}: $gn"
            }
            else { $label }
        }) -join '; '

    $results.Add([PSCustomObject]@{
            Status     = $state
            Category   = $def.Cat
            ObjectType = Get-ObjectTypeLabel $def $obj
            Name       = $obj.($def.Name)
            ScopeTags  = $tags
            Targets    = $targets
            ObjectId   = $obj.id
        })
}
#endregion

#region Result and export
$order = @{ Unassigned = 1; ExcludeOnly = 2; DeletedGroupsOnly = 3; SomeDeletedGroups = 4 }
$sorted = @($results | Sort-Object { $order[$_.Status] }, Category, ObjectType, Name)

Write-Host ''
Write-Host '==================================================================' -ForegroundColor Cyan
Write-Host ' Intune objects that apply to nobody (or reference deleted groups)' -ForegroundColor Cyan
Write-Host '==================================================================' -ForegroundColor Cyan
foreach ($s in 'Unassigned', 'ExcludeOnly', 'DeletedGroupsOnly', 'SomeDeletedGroups') {
    if ($Status -notcontains $s) { continue }
    $rows = @($sorted | Where-Object Status -eq $s)
    Write-Host "`n$s ($($rows.Count)):" -ForegroundColor Yellow
    if ($rows.Count) {
        if ($s -eq 'Unassigned') { $rows | Format-Table Category, ObjectType, Name, ScopeTags -AutoSize -Wrap | Out-Host }
        else { $rows | Format-Table Category, ObjectType, Name, ScopeTags, Targets -AutoSize -Wrap | Out-Host }
    }
    else { Write-Host '  (none)' -ForegroundColor DarkGray }
}

Write-Host '------------------------------------------------------------------' -ForegroundColor Cyan
Write-Host ("Checked objects: {0}   Findings: {1}" -f $found.Count, $sorted.Count) -ForegroundColor Cyan
if ($skipped.Count) {
    Write-Host "NOT checked ($($skipped.Count)) - result is incomplete for these types:" -ForegroundColor DarkYellow
    $skipped | Format-Table ObjectType, Reason -AutoSize | Out-Host
}
Write-Host 'Note: objects outside your Intune scope tags are invisible to Graph and therefore missing here.' -ForegroundColor DarkGray

if ($ExportCsv) {
    $path = Join-Path $OutputFolder ("IntuneUnassigned_{0}.csv" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
    $sorted | Export-Csv -Path $path -NoTypeInformation -Delimiter ';' -Encoding UTF8
    Write-Host "Exported: $path" -ForegroundColor Green
}

if ($PassThru) { return $sorted }
#endregion
