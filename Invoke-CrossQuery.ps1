param (
    [Parameter(Mandatory)]$table,
    [Parameter(Mandatory)]$inputQuery
    )

$subscriptions = Get-AzSubscription
$workspaces = @()
$buildQuery = $null
$workingWorkspaceId = "Specify here the workspace id of the workspace you usually work from."

foreach ($subscription in $subscriptions) {

    Select-AzSubscription $subscription
    $workspace = Get-AzOperationalInsightsWorkspace | Select-Object -ExpandProperty Name
    $workspaces += $workspace
    $workspaces = $workspaces -notmatch "specify here the name of the workspace you usually work from so that it is not queried twice"

}

foreach ($workspace in $workspaces) {

    $buildQuery += ",workspace(`"$($workspace)`").$table"

}

$query = @"
union $table$buildQuery$inputQuery
"@

$output = (Invoke-AzOperationalInsightsQuery -WorkspaceId $workingWorkspaceId -Query $query).Results

$output