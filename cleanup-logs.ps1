param(
    [string]$LogPath = "C:\Logs",
    [int]$DaysToKeep = 14,
    [string]$ReportPath = ".\reports"
)

if (-not (Test-Path $ReportPath)) {
    New-Item -ItemType Directory -Path $ReportPath | Out-Null
}

$now = Get-Date
$cutoff = $now.AddDays(-$DaysToKeep)

$beforeSize = (Get-ChildItem -Path $LogPath -Recurse -ErrorAction SilentlyContinue | 
    Measure-Object -Property Length -Sum).Sum

# Delete old files
$deleted = Get-ChildItem -Path $LogPath -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -lt $cutoff }

$deletedCount = 0
$deletedSize = 0

foreach ($file in $deleted) {
    $deletedSize += $file.Length
    Remove-Item -Path $file.FullName -Force -ErrorAction SilentlyContinue
    $deletedCount++
}

$afterSize = (Get-ChildItem -Path $LogPath -Recurse -ErrorAction SilentlyContinue | 
    Measure-Object -Property Length -Sum).Sum

$report = [PSCustomObject]@{
    DateTime        = $now
    LogPath         = $LogPath
    DaysToKeep      = $DaysToKeep
    FilesDeleted    = $deletedCount
    SpaceFreedBytes = $deletedSize
    SizeBeforeBytes = $beforeSize
    SizeAfterBytes  = $afterSize
}

$reportFile = Join-Path $ReportPath ("log_cleanup_{0:yyyyMMdd_HHmmss}.csv" -f $now)
$report | Export-Csv -Path $reportFile -NoTypeInformation

Write-Host "Deleted $deletedCount files."
Write-Host "Freed $deletedSize bytes."
Write-Host "Report written to $reportFile."
