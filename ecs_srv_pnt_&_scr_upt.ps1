# PowerShell v1.0 Compatible ECS File Copy Script
# Copies files and directories

# --- Configuration ---
$MdbSourceFolder = "C:\tmp\source\FlsaProDb"    # Source folder for MDB files
$MdbDestinationFolder = "C:\tmp\dest\FlsaDev\ProDb" # Destination folder for MDB files

$PicSourceFolder = "C:\tmp\source\FlsaGmsPic\ECS2261"  # Source folder for directory copy
$PicDestinationFolder = "C:\tmp\dest\FlsaDev\GMSPic\Ops\ECS2261" # Destination folder for directory copy

# Files to copy with replacement
$FilesToCopy = "SdrApAlg30.mdb", "SdrBlkAlg30.mdb", "SdrBpAlg30.mdb", "SdrPoint30.mdb", "SdrSimS5Config30.mdb"

# --- Check administrator rights ---
# $CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
# $Principal = new-object System.Security.Principal.WindowsPrincipal($CurrentUser)
# $IsAdmin = $Principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

# if (-not $IsAdmin) {
#     Write-Host "ERROR: This script requires administrator privileges to run." -ForegroundColor Red
#     Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Red
#     exit 1
# }

# --- Validate folder paths ---
if (-not (Test-Path $MdbSourceFolder)) {
    Write-Host "ERROR: MDB source folder does not exist: $MdbSourceFolder" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $MdbDestinationFolder)) {
    Write-Host "ERROR: MDB destination folder does not exist: $MdbDestinationFolder" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $PicSourceFolder)) {
    Write-Host "ERROR: Picture source folder does not exist: $PicSourceFolder" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $PicDestinationFolder)) {
    Write-Host "Creating destination directory: $PicDestinationFolder" -ForegroundColor Yellow
    $Error.Clear()
    New-Item -Path $PicDestinationFolder -ItemType Directory -Force -ErrorAction SilentlyContinue
    if ($Error.Count -gt 0) {
        Write-Host "ERROR: Could not create destination folder: $PicDestinationFolder" -ForegroundColor Red
        exit 1
    }
}

Write-Host "ECS File Copy Script Starting..." -ForegroundColor Green
Write-Host "MDB Source: $MdbSourceFolder" -ForegroundColor Cyan
Write-Host "MDB Destination: $MdbDestinationFolder" -ForegroundColor Cyan
Write-Host "Picture Source: $PicSourceFolder" -ForegroundColor Cyan
Write-Host "Picture Destination: $PicDestinationFolder" -ForegroundColor Cyan

# --- Step 1: Copy MDB Files ---
Write-Host ""
Write-Host "Step 1: Copying MDB files..." -ForegroundColor Yellow
$CopiedFiles = 0
$FailedFiles = 0

foreach ($FileName in $FilesToCopy) {
    $SourceFile = Join-Path $MdbSourceFolder $FileName
    $DestinationFile = Join-Path $MdbDestinationFolder $FileName
    
    if (Test-Path $SourceFile) {
        Write-Host "Copying: $FileName" -ForegroundColor White
        
        $Error.Clear()
        
        # Create backup of existing file if it exists
        if (Test-Path $DestinationFile) {
            $BackupFile = $DestinationFile + ".backup." + (Get-Date -Format "yyyyMMdd_HHmmss")
            Copy-Item -Path $DestinationFile -Destination $BackupFile -ErrorAction SilentlyContinue
            if ($Error.Count -eq 0) {
                $BackupFileName = Split-Path $BackupFile -Leaf
                Write-Host "  Backup created: $BackupFileName" -ForegroundColor Gray
            }
        }
        
        # Copy new file
        Copy-Item -Path $SourceFile -Destination $DestinationFile -Force -ErrorAction SilentlyContinue
        
        # Check if copy operation succeeded
        if ($Error.Count -eq 0 -and (Test-Path $DestinationFile)) {
            Write-Host "  File copied successfully" -ForegroundColor Green
            $CopiedFiles++
        }
        else {
            Write-Host "  Failed to copy file: $FileName" -ForegroundColor Red
            $FailedFiles++
        }
    }
    else {
        Write-Host "WARNING: Source file not found: $SourceFile" -ForegroundColor Yellow
        $FailedFiles++
    }
}

Write-Host "MDB Files copied: $CopiedFiles, Failed: $FailedFiles" -ForegroundColor Green

# --- Step 2: Copy GMSPic Directory with all files and subdirectories ---
Write-Host ""
Write-Host "Step 2: Copying directory and all contents..." -ForegroundColor Yellow
$DirCopySuccess = $false

Write-Host "Copying from: $PicSourceFolder" -ForegroundColor White
Write-Host "Copying to: $PicDestinationFolder" -ForegroundColor White

$Error.Clear()

# Create backup of existing directory if it exists
if (Test-Path $PicDestinationFolder) {
    $BackupDir = $PicDestinationFolder + ".backup." + (Get-Date -Format "yyyyMMdd_HHmmss")
    Write-Host "Creating backup: $BackupDir" -ForegroundColor Gray
    Copy-Item -Path $PicDestinationFolder -Destination $BackupDir -Recurse -ErrorAction SilentlyContinue
}

# Remove existing destination directory to ensure clean copy
if (Test-Path $PicDestinationFolder) {
    Remove-Item -Path $PicDestinationFolder -Recurse -Force -ErrorAction SilentlyContinue
}

# Copy the entire directory structure
Copy-Item -Path $PicSourceFolder -Destination $PicDestinationFolder -Recurse -Force -ErrorAction SilentlyContinue

# Check if directory copy operation succeeded
if ($Error.Count -eq 0 -and (Test-Path $PicDestinationFolder)) {
    Write-Host "  Directory GMSPic copied successfully" -ForegroundColor Green
    $DirCopySuccess = $true
}
else {
    Write-Host "  Failed to copy directory GMSPic" -ForegroundColor Red
    $DirCopySuccess = $false
}

# --- Summary ---
Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "ECS FILE COPY COMPLETE" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "MDB Files copied: $CopiedFiles"
Write-Host "MDB Files failed: $FailedFiles"
Write-Host "GMSPic Directory copy: $(if ($DirCopySuccess) { 'Success' } else { 'Failed' })"

if ($FailedFiles -eq 0 -and $DirCopySuccess) {
    Write-Host ""
    Write-Host "Operation completed successfully!" -ForegroundColor Green
    
    # --- Ask for system restart ---
    Write-Host ""
    Write-Host "Do you want to restart Windows now? (Y/N): " -ForegroundColor Yellow -NoNewline
    $RestartChoice = Read-Host
    
    if ($RestartChoice -eq "Y" -or $RestartChoice -eq "y" -or $RestartChoice -eq "Yes" -or $RestartChoice -eq "yes") {
        Write-Host "Restarting Windows in 10 seconds..." -ForegroundColor Red
        Write-Host "Press Ctrl+C to cancel" -ForegroundColor Yellow
        Start-Sleep -Seconds 10
        
        Write-Host "Initiating system restart..." -ForegroundColor Red
        Restart-Computer -Force
    }
    else {
        Write-Host "System restart cancelled by user." -ForegroundColor Green
    }
    
    exit 0
}
else {
    Write-Host ""
    Write-Host "Operation completed with errors. Please review the output above." -ForegroundColor Yellow
    Write-Host "System restart not recommended due to errors." -ForegroundColor Red
    exit 1
}