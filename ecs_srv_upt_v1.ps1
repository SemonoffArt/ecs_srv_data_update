# PowerShell v1.0 Compatible ECS Service Update Script
# Stops services, copies files, and restarts services

# --- Configuration ---
$SourceFolder = "C:\tmp\source"  # Source folder for files
$DestinationFolder = "C:\tmp\dest" # Destination folder for files

# Services to stop and restart
$ServicesToManage = "SdrOpcHdaSvr30", "SdrPLCParamsSvr30", "SdrPointSvr30", "SdrRepScheduleSvr30", "SdrStartHelperRpc30", "SdrSAAMServer.3", "SdrSimS5Svr30", "SdrLogSvr30"

# Files to copy with replacement
$FilesToCopy = "SdrApAlg30.mdb", "SdrBlkAlg30.mdb", "SdrBpAlg30.mdb", "SdrPoint30.mdb", "SdrSimS5Config30.mdb"

# --- Check administrator rights ---
$CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = new-object System.Security.Principal.WindowsPrincipal($CurrentUser)
$IsAdmin = $Principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Write-Host "ERROR: This script requires administrator privileges to run." -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Red
    exit 1
}

# --- Validate folder paths ---
if (-not (Test-Path $SourceFolder)) {
    Write-Host "ERROR: Source folder does not exist: $SourceFolder" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $DestinationFolder)) {
    Write-Host "ERROR: Destination folder does not exist: $DestinationFolder" -ForegroundColor Red
    exit 1
}

Write-Host "ECS Service Update Script Starting..." -ForegroundColor Green
Write-Host "Source: $SourceFolder" -ForegroundColor Cyan
Write-Host "Destination: $DestinationFolder" -ForegroundColor Cyan

# --- Step 1: Stop Services ---
Write-Host ""
Write-Host "Step 1: Stopping services..." -ForegroundColor Yellow
$StoppedServices = @()

foreach ($ServiceName in $ServicesToManage) {
    $Service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    
    if ($Service) {
        if ($Service.Status -eq "Running") {
            Write-Host "Stopping service: $ServiceName" -ForegroundColor White
            try {
                Stop-Service -Name $ServiceName -Force
                $StoppedServices += $ServiceName
                Write-Host "  Service stopped successfully" -ForegroundColor Green
            }
            catch {
                Write-Host "  Failed to stop service: $ServiceName" -ForegroundColor Red
            }
        }
        elseif ($Service.Status -eq "Stopped") {
            Write-Host "Service already stopped: $ServiceName" -ForegroundColor Gray
        }
        else {
            Write-Host "Service in state '$($Service.Status)': $ServiceName" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "WARNING: Service not found: $ServiceName" -ForegroundColor Yellow
    }
}

Write-Host "Services stopped: $($StoppedServices.Count)" -ForegroundColor Green

# --- Step 2: Copy Files ---
Write-Host ""
Write-Host "Step 2: Copying files..." -ForegroundColor Yellow
$CopiedFiles = 0
$FailedFiles = 0

foreach ($FileName in $FilesToCopy) {
    $SourceFile = Join-Path $SourceFolder $FileName
    $DestinationFile = Join-Path $DestinationFolder $FileName
    
    if (Test-Path $SourceFile) {
        Write-Host "Copying: $FileName" -ForegroundColor White
        
        try {
            # Create backup of existing file if it exists
            if (Test-Path $DestinationFile) {
                $BackupFile = $DestinationFile + ".backup." + (Get-Date -Format "yyyyMMdd_HHmmss")
                Copy-Item -Path $DestinationFile -Destination $BackupFile
                $BackupFileName = Split-Path $BackupFile -Leaf
                Write-Host "  Backup created: $BackupFileName" -ForegroundColor Gray
            }
            
            # Copy new file
            Copy-Item -Path $SourceFile -Destination $DestinationFile -Force
            
            # Verify copy was successful
            if (Test-Path $DestinationFile) {
                Write-Host "  File copied successfully" -ForegroundColor Green
                $CopiedFiles++
            }
            else {
                Write-Host "  File copy verification failed" -ForegroundColor Red
                $FailedFiles++
            }
        }
        catch {
            Write-Host "  Failed to copy file: $FileName" -ForegroundColor Red
            $FailedFiles++
        }
    }
    else {
        Write-Host "WARNING: Source file not found: $SourceFile" -ForegroundColor Yellow
        $FailedFiles++
    }
}

Write-Host "Files copied: $CopiedFiles, Failed: $FailedFiles" -ForegroundColor Green

# --- Step 3: Start Services ---
Write-Host ""
Write-Host "Step 3: Starting services..." -ForegroundColor Yellow
$StartedServices = 0
$FailedStarts = 0

foreach ($ServiceName in $StoppedServices) {
    Write-Host "Starting service: $ServiceName" -ForegroundColor White
    try {
        Start-Service -Name $ServiceName
        
        # Wait a moment and verify service started
        Start-Sleep -Seconds 2
        $Service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        
        if ($Service -and $Service.Status -eq "Running") {
            Write-Host "  Service started successfully" -ForegroundColor Green
            $StartedServices++
        }
        else {
            if ($Service) {
                Write-Host "  Service may not have started properly (Status: $($Service.Status))" -ForegroundColor Yellow
            }
            else {
                Write-Host "  Could not verify service status" -ForegroundColor Yellow
            }
            $FailedStarts++
        }
    }
    catch {
        Write-Host "  Failed to start service: $ServiceName" -ForegroundColor Red
        $FailedStarts++
    }
}

# --- Summary ---
Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "ECS SERVICE UPDATE COMPLETE" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Services stopped: $($StoppedServices.Count)"
Write-Host "Files copied: $CopiedFiles"
Write-Host "Files failed: $FailedFiles"
Write-Host "Services restarted: $StartedServices"
Write-Host "Service start failures: $FailedStarts"

if ($FailedFiles -eq 0 -and $FailedStarts -eq 0) {
    Write-Host ""
    Write-Host "Operation completed successfully!" -ForegroundColor Green
    exit 0
}
else {
    Write-Host ""
    Write-Host "Operation completed with errors. Please review the output above." -ForegroundColor Yellow
    exit 1
}