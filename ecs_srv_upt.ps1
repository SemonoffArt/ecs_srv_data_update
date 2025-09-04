# requires -version 2.0

# ECS Service Update Script
# Stops services, copies files, and restarts services

# --- Configuration ---
$SourceFolder = "C:\Users\7Arrt\Desktop\Projects\ecs_srv_data_update\tmp\source"  # Source folder for files
$DestinationFolder = "C:\Users\7Arrt\Desktop\Projects\ecs_srv_data_update\tmp\dest" # Destination folder for files

# Services to stop and restart
$ServicesToManage = @(
    "SdrOpcHdaSvr30",
    "SdrPLCParamsSvr30", 
    "SdrPointSvr30",
    "SdrRepScheduleSvr30",
    "SdrStartHelperRpc30",
    "SdrSAAMServer.3",
    "SdrSimS5Svr30",
    "SdrLogSvr30"
)

# Files to copy with replacement
$FilesToCopy = @(
    "SdrApAlg30.mdb",
    "SdrBlkAlg30.mdb", 
    "SdrBpAlg30.mdb",
    "SdrPoint30.mdb",
    "SdrSimS5Config30.mdb"
)

# --- Check administrator rights ---
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $IsAdmin) {
    Write-Error "This script requires administrator privileges to run."
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Red
    exit 1
}

# --- Validate folder paths ---
if (-not (Test-Path $SourceFolder)) {
    Write-Error "Source folder does not exist: $SourceFolder"
    exit 1
}

if (-not (Test-Path $DestinationFolder)) {
    Write-Error "Destination folder does not exist: $DestinationFolder"
    exit 1
}

Write-Host "ECS Service Update Script Starting..." -ForegroundColor Green
Write-Host "Source: $SourceFolder" -ForegroundColor Cyan
Write-Host "Destination: $DestinationFolder" -ForegroundColor Cyan

# --- Step 1: Stop Services ---
Write-Host "`nStep 1: Stopping services..." -ForegroundColor Yellow
$StoppedServices = @()

foreach ($ServiceName in $ServicesToManage) {
    try {
        $Service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        
        if ($Service) {
            if ($Service.Status -eq "Running") {
                Write-Host "Stopping service: $ServiceName" -ForegroundColor White
                Stop-Service -Name $ServiceName -Force -ErrorAction Stop
                $StoppedServices += $ServiceName
                Write-Host "  Service stopped successfully" -ForegroundColor Green
            }
            elseif ($Service.Status -eq "Stopped") {
                Write-Host "Service already stopped: $ServiceName" -ForegroundColor Gray
            }
            else {
                Write-Host "Service in state '$($Service.Status)': $ServiceName" -ForegroundColor Yellow
            }
        }
        else {
            Write-Warning "Service not found: $ServiceName"
        }
    }
    catch {
        Write-Error "Failed to stop service '$ServiceName': $($_.Exception.Message)"
    }
}

Write-Host "Services stopped: $($StoppedServices.Count)" -ForegroundColor Green

# --- Step 2: Copy Files ---
Write-Host "`nStep 2: Copying files..." -ForegroundColor Yellow
$CopiedFiles = 0
$FailedFiles = 0

foreach ($FileName in $FilesToCopy) {
    $SourceFile = Join-Path $SourceFolder $FileName
    $DestinationFile = Join-Path $DestinationFolder $FileName
    
    try {
        if (Test-Path $SourceFile) {
            Write-Host "Copying: $FileName" -ForegroundColor White
            
            # Create backup of existing file if it exists
            if (Test-Path $DestinationFile) {
                $BackupFile = $DestinationFile + ".backup." + (Get-Date -Format "yyyyMMdd_HHmmss")
                Copy-Item -Path $DestinationFile -Destination $BackupFile -ErrorAction Stop
                Write-Host "  Backup created: $(Split-Path $BackupFile -Leaf)" -ForegroundColor Gray
            }
            
            # Copy new file
            Copy-Item -Path $SourceFile -Destination $DestinationFile -Force -ErrorAction Stop
            
            # Verify copy was successful
            if (Test-Path $DestinationFile) {
                Write-Host "  File copied successfully" -ForegroundColor Green
                $CopiedFiles++
            }
            else {
                Write-Error "  File copy verification failed"
                $FailedFiles++
            }
        }
        else {
            Write-Warning "Source file not found: $SourceFile"
            $FailedFiles++
        }
    }
    catch {
        Write-Error "Failed to copy '$FileName': $($_.Exception.Message)"
        $FailedFiles++
    }
}

Write-Host "Files copied: $CopiedFiles, Failed: $FailedFiles" -ForegroundColor Green

# --- Step 3: Start Services ---
Write-Host "`nStep 3: Starting services..." -ForegroundColor Yellow
$StartedServices = 0
$FailedStarts = 0

foreach ($ServiceName in $StoppedServices) {
    try {
        Write-Host "Starting service: $ServiceName" -ForegroundColor White
        Start-Service -Name $ServiceName -ErrorAction Stop
        
        # Wait a moment and verify service started
        Start-Sleep -Seconds 2
        $Service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        
        if ($Service -and $Service.Status -eq "Running") {
            Write-Host "  Service started successfully" -ForegroundColor Green
            $StartedServices++
        }
        else {
            Write-Warning "  Service may not have started properly (Status: $($Service.Status))"
            $FailedStarts++
        }
    }
    catch {
        Write-Error "Failed to start service '$ServiceName': $($_.Exception.Message)"
        $FailedStarts++
    }
}

# --- Summary ---
Write-Host "`n" + "="*50 -ForegroundColor Cyan
Write-Host "ECS SERVICE UPDATE COMPLETE" -ForegroundColor Green
Write-Host "="*50 -ForegroundColor Cyan
Write-Host "Services stopped: $($StoppedServices.Count)"
Write-Host "Files copied: $CopiedFiles"
Write-Host "Files failed: $FailedFiles"
Write-Host "Services restarted: $StartedServices"
Write-Host "Service start failures: $FailedStarts"

if ($FailedFiles -eq 0 -and $FailedStarts -eq 0) {
    Write-Host "`nOperation completed successfully!" -ForegroundColor Green
    exit 0
}
else {
    Write-Host "`nOperation completed with errors. Please review the output above." -ForegroundColor Yellow
    exit 1
}