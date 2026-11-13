#Requires -Version 5.1
<#
.SYNOPSIS
    Compares the iterative-refinement working copy against install directories (hash check, anti-drift).
.DESCRIPTION
    Maintainer tool; not loaded during skill execution.
    Compares relative paths and MD5 hashes file by file.
    Prints one line per missing / mismatched / extra file.
    Exit codes: 0 = all in sync; 1 = drift/missing/extra detected; 2 = input error.
.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/sync-check.ps1 -WorkingCopy "D:\path\to\iterative-refinement" -InstallDirs "C:\path\A\iterative-refinement;D:\path\B\iterative-refinement"
#>
param(
    [Parameter(Mandatory = $true)][string]$WorkingCopy,
    [Parameter(Mandatory = $true)][string]$InstallDirs
)

$ErrorActionPreference = 'Stop'
$failures = 0

# -File mode cannot bind array parameters reliably; accept one semicolon-separated string instead
$dirList = $InstallDirs -split ';' | ForEach-Object { $_.Trim() } | Where-Object { $_ }

if ($dirList.Count -eq 0) {
    Write-Output "[FAIL] no install dir specified"
    exit 2
}

if (-not (Test-Path $WorkingCopy)) {
    Write-Output "[FAIL] working copy not found: $WorkingCopy"
    exit 2
}

# Normalize to absolute provider paths so Substring prefix assumptions hold
$WorkingCopy = (Resolve-Path $WorkingCopy).ProviderPath

$workFiles = Get-ChildItem -Recurse -File $WorkingCopy

foreach ($dir in $dirList) {
    if (-not (Test-Path $dir)) {
        Write-Output "[FAIL] install dir not found: $dir"
        $failures++
        continue
    }
    $dir = (Resolve-Path $dir).ProviderPath
    $issues = @()

    # 1) every file in the working copy must exist in the install dir with identical hash
    foreach ($f in $workFiles) {
        $rel = $f.FullName.Substring($WorkingCopy.Length)
        $target = Join-Path $dir $rel
        if (-not (Test-Path $target)) {
            $issues += "missing: $rel"
        }
        elseif ((Get-FileHash $f.FullName -Algorithm MD5).Hash -ne (Get-FileHash $target -Algorithm MD5).Hash) {
            $issues += "mismatch: $rel"
        }
    }

    # 2) extra files present only in the install dir
    foreach ($f in (Get-ChildItem -Recurse -File $dir)) {
        $rel = $f.FullName.Substring($dir.Length)
        if (-not (Test-Path (Join-Path $WorkingCopy $rel))) {
            $issues += "extra: $rel"
        }
    }

    if ($issues.Count -eq 0) {
        Write-Output "[OK]   $dir"
    }
    else {
        foreach ($i in $issues) { Write-Output "[FAIL] $dir :: $i" }
        $failures += $issues.Count
    }
}

if ($failures -gt 0) { exit 1 } else { exit 0 }
