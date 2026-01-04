# Unblock all files in a directory
# This script removes the "blocked" status from files downloaded from the internet

param(
    [Parameter(Mandatory=$false)]
    [string]$Path = ".",
    
    [Parameter(Mandatory=$false)]
    [switch]$Recurse
)

# Resolve the full path
$FullPath = Resolve-Path $Path -ErrorAction SilentlyContinue

if (-not $FullPath) {
    Write-Host "Error: Path '$Path' not found" -ForegroundColor Red
    exit 1
}

Write-Host "Unblocking files in: $FullPath" -ForegroundColor Cyan

# Build the Get-ChildItem parameters
$params = @{
    Path = $FullPath
    File = $true
}

if ($Recurse) {
    $params.Add('Recurse', $true)
    Write-Host "Mode: Recursive (including subdirectories)" -ForegroundColor Yellow
} else {
    Write-Host "Mode: Current directory only" -ForegroundColor Yellow
}

# Get all files
$files = Get-ChildItem @params

$total = $files.Count
$unblocked = 0

Write-Host "`nProcessing $total file(s)...`n" -ForegroundColor Green

foreach ($file in $files) {
    try {
        # Check if file is blocked
        $zone = Get-Content -Path $file.FullName -Stream Zone.Identifier -ErrorAction SilentlyContinue
        
        if ($zone) {
            # Unblock the file
            Unblock-File -Path $file.FullName
            Write-Host "[UNBLOCKED] $($file.FullName)" -ForegroundColor Green
            $unblocked++
        }
    }
    catch {
        Write-Host "[ERROR] Failed to process: $($file.FullName)" -ForegroundColor Red
    }
}

Write-Host "`n" -NoNewline
Write-Host "Complete! " -ForegroundColor Cyan -NoNewline
Write-Host "Unblocked $unblocked of $total file(s)" -ForegroundColor White

# Usage examples:
# .\unblock_files.ps1                          # Unblock files in current directory
# .\unblock_files.ps1 -Path "C:\Downloads"     # Unblock files in specific directory
# .\unblock_files.ps1 -Recurse                 # Unblock files in current directory and subdirectories
# .\unblock_files.ps1 -Path "C:\Downloads" -Recurse  # Unblock files recursively in specific directory