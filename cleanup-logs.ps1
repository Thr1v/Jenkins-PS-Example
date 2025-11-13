param(
    [string]$LogPath = "C:\Logs",
    [int]$DaysThreshold = 14,
    [string]$ReportPath = ".\reports"
)

if (-not (Test-Path $ReportPath)) {
    New-Item -ItemType Directory -Path $ReportPath | Out-Null
}

$now = Get-Date
$cutoff = $now.AddDays(-$DaysThreshold)

# Get all files under the log path
$allFiles = Get-ChildItem -Path $LogPath -Recurse -File -ErrorAction SilentlyContinue

$totalFiles = $allFiles.Count
$totalSizeBytes = ($allFiles | Measure-Object -Property Length -Sum).Sum

# Files older than cutoff (but we DON'T delete them)
$oldFiles = $allFiles | Where-Object { $_.LastWriteTime -lt $cutoff }
$oldFilesCount = $oldFiles.Count
$oldFilesSizeBytes = ($oldFiles | Measure-Object -Property Length -Sum).Sum

$report = [PSCustomObject]@{
    DateTime          = $now
    LogPath           = $LogPath
    DaysThreshold     = $DaysThreshold
    TotalFiles        = $totalFiles
    TotalSizeBytes    = $totalSizeBytes
    OldFilesCount     = $oldFilesCount
    OldFilesSizeBytes = $oldFilesSizeBytes
}

$reportFile = Join-Path $ReportPath ("log_metrics_{0:yyyyMMdd_HHmmss}.csv" -f $now)
$report | Export-Csv -Path $reportFile -NoTypeInformation

Write-Host "Scanned log path: $LogPath"
Write-Host "Total files: $totalFiles"
Write-Host "Total size (bytes): $totalSizeBytes"
Write-Host "Files older than $DaysThreshold days: $oldFilesCount"
Write-Host "Old files size (bytes): $oldFilesSizeBytes"
Write-Host "Report written to $reportFile"
