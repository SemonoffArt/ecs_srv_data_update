# PowerShell v1.0 Compatible ECS File Copy Script
# Copies files and directories
# (Service management functionality is commented out)

# --- Configuration ---
$MdbSourceFolder = "\\ECS2261SVR02\FlsaProDb"    # Network source folder for MDB files
$MdbDestinationFolder = "C:\FlsaDev\ProDb" # Destination folder for MDB files

$PicSourceFolder = "\\ECS2261SVR02\FlsaGmsPic\ECS2261"  # Network source folder for directory copy
$PicDestinationFolder = "C:\FlsaDev\GMSPic\Ops\ECS2261" # Destination folder for directory copy

# Services to stop and restart (commented out)
# $ServicesToManage = "SdrOpcHdaSvr30", "SdrPLCParamsSvr30", "SdrPointSvr30", "SdrRepScheduleSvr30", "SdrStartHelperRpc30", "SdrSAAMServer.3", "SdrSimS5Svr30", "SdrLogSvr30"

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
    Write-Host "ERROR: Network MDB source folder not accessible: $MdbSourceFolder" -ForegroundColor Red
    Write-Host "Please check network connectivity and share permissions." -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path $MdbDestinationFolder)) {
    Write-Host "ERROR: MDB destination folder does not exist: $MdbDestinationFolder" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $PicSourceFolder)) {
    Write-Host "ERROR: Network picture source folder not accessible: $PicSourceFolder" -ForegroundColor Red
    Write-Host "Please check network connectivity and share permissions." -ForegroundColor Yellow
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

# --- User Confirmation ---
Write-Host ""
Write-Host "Execute ECS3 data update? (yes/no): " -ForegroundColor Yellow -NoNewline
$UserChoice = Read-Host

if ($UserChoice -eq "yes" -or $UserChoice -eq "Yes" -or $UserChoice -eq "YES" -or $UserChoice -eq "y" -or $UserChoice -eq "Y") {
    Write-Host "Continuing with data update execution..." -ForegroundColor Green
}
else {
    Write-Host "Data update cancelled by user." -ForegroundColor Red
    Write-Host "Script execution terminated." -ForegroundColor Yellow
    exit 0
}

# --- Step 0: Stop Services (COMMENTED OUT) ---
# После перезапуска служб - ECS клиент не может подключиться (синий или белый экран)), 
# пока нашёл такой способ решения - перезагрузка windows.
# Write-Host ""
# Write-Host "Step 0: Stopping services..." -ForegroundColor Yellow
# $StoppedServices = @()
# 
# foreach ($ServiceName in $ServicesToManage) {
#     $Service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
#     
#     if ($Service) {
#         if ($Service.Status -eq "Running") {
#             Write-Host "Stopping service: $ServiceName" -ForegroundColor White
#             $Error.Clear()
#             Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
#             if ($Error.Count -eq 0) {
#                 $StoppedServices += $ServiceName
#                 Write-Host "  Service stopped successfully" -ForegroundColor Green
#             }
#             else {
#                 Write-Host "  Failed to stop service: $ServiceName" -ForegroundColor Red
#             }
#         }
#         elseif ($Service.Status -eq "Stopped") {
#             Write-Host "Service already stopped: $ServiceName" -ForegroundColor Gray
#         }
#         else {
#             Write-Host "Service in state '$($Service.Status)': $ServiceName" -ForegroundColor Yellow
#         }
#     }
#     else {
#         Write-Host "WARNING: Service not found: $ServiceName" -ForegroundColor Yellow
#     }
# }
# 
# Write-Host "Services stopped: $($StoppedServices.Count)" -ForegroundColor Green

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

# --- Step 3: Start Services (COMMENTED OUT) ---
# Write-Host ""
# Write-Host "Step 3: Starting services..." -ForegroundColor Yellow
# $StartedServices = 0
# $FailedStarts = 0
# 
# foreach ($ServiceName in $StoppedServices) {
#     Write-Host "Starting service: $ServiceName" -ForegroundColor White
#     $Error.Clear()
#     Start-Service -Name $ServiceName -ErrorAction SilentlyContinue
#     
#     if ($Error.Count -eq 0) {
#         # Wait a moment and verify service started
#         Start-Sleep -Seconds 2
#         $Service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
#         
#         if ($Service -and $Service.Status -eq "Running") {
#             Write-Host "  Service started successfully" -ForegroundColor Green
#             $StartedServices++
#         }
#         else {
#             if ($Service) {
#                 Write-Host "  Service may not have started properly (Status: $($Service.Status))" -ForegroundColor Yellow
#             }
#             else {
#                 Write-Host "  Could not verify service status" -ForegroundColor Yellow
#             }
#             $FailedStarts++
#         }
#     }
#     else {
#         Write-Host "  Failed to start service: $ServiceName" -ForegroundColor Red
#         $FailedStarts++
#     }
# }

# --- Summary ---
Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "ECS FILE COPY COMPLETE" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "MDB Files copied: $CopiedFiles"
Write-Host "MDB Files failed: $FailedFiles"
Write-Host "GMSPic Directory copy: $(if ($DirCopySuccess) { 'Success' } else { 'Failed' })"
# Write-Host "Services stopped: $($StoppedServices.Count)" (commented out)
# Write-Host "Services restarted: $StartedServices" (commented out)
# Write-Host "Service start failures: $FailedStarts" (commented out)

# --- Step 4: Restart Windows  ---
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
        # Use shutdown.exe for PowerShell v1.0 compatibility
        shutdown.exe /r /t 0 /f
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