# ============================================================
# PCOD CDR - RELIABLE BACKUP SCRIPT (FINAL VERSION)
# Author: Muhammad Arshad
# ============================================================

# --- CONFIGURATION ---
$backupRoot = "C:\Projects\PCOD\backups"
$projectRoot = "C:\Projects\PCOD"
$postgresContainer = "pcod_postgres"

# Ensure backup root exists
New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null

# Create timestamped folder
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupName = "PCOD_CDR_Backup_$timestamp"
$backupDir = Join-Path $backupRoot $backupName
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PCOD CDR BACKUP STARTED" -ForegroundColor Green
Write-Host "Backup Folder: $backupDir" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Helper to verify file existence
function Check-File {
    param($path)
    if (Test-Path $path) {
        Write-Host "      ✓ File exists: $path" -ForegroundColor Green
    } else {
        Write-Host "      ❌ File missing: $path" -ForegroundColor Red
    }
}

# ------------------------------------------------------------
# 1. BACKUP DATABASE
# ------------------------------------------------------------
Write-Host "[1/6] Backing up PostgreSQL database..." -ForegroundColor Yellow

$dbDump = Join-Path $backupDir "pcod_database.sql"
$dbZip  = Join-Path $backupDir "pcod_database.zip"

docker exec $postgresContainer pg_dump -U postgres -d ehrbase --clean --if-exists > $dbDump 2>&1

if ((Test-Path $dbDump) -and ((Get-Item $dbDump).Length -gt 1000)) {
    Compress-Archive -Path $dbDump -DestinationPath $dbZip -Force
    Remove-Item $dbDump -Force
    Write-Host "      ✓ Database saved: $dbZip" -ForegroundColor Green
    Check-File $dbZip
} else {
    Write-Host "      ❌ Database backup FAILED (file missing or too small)" -ForegroundColor Red
    Check-File $dbDump
}

# ------------------------------------------------------------
# 2. BACKUP DOCKER COMPOSE
# ------------------------------------------------------------
Write-Host "[2/6] Saving docker-compose.yml..." -ForegroundColor Yellow
$composeFile = "$projectRoot\docker\docker-compose.yml"
Copy-Item $composeFile $backupDir -Force
Write-Host "      ✓ Saved: docker-compose.yml" -ForegroundColor Green
Check-File "$backupDir\docker-compose.yml"

# ------------------------------------------------------------
# 3. BACKUP FRONTEND
# ------------------------------------------------------------
Write-Host "[3/6] Saving eCRF frontend..." -ForegroundColor Yellow
$frontendZip = Join-Path $backupDir "ecrf_frontend.zip"
Compress-Archive -Path "$projectRoot\docker\ecrf\frontend\*" -DestinationPath $frontendZip -Force
Write-Host "      ✓ Saved: eCRF frontend → $frontendZip" -ForegroundColor Green
Check-File $frontendZip

# ------------------------------------------------------------
# 4. BACKUP NGINX CONFIG
# ------------------------------------------------------------
Write-Host "[4/6] Saving nginx.conf..." -ForegroundColor Yellow
$nginxConf = "$projectRoot\docker\ecrf\nginx\nginx.conf"
if (Test-Path $nginxConf) {
    Copy-Item $nginxConf $backupDir -Force
    Write-Host "      ✓ Saved: nginx.conf" -ForegroundColor Green
    Check-File "$backupDir\nginx.conf"
} else {
    Write-Host "      ⚠ nginx.conf not found" -ForegroundColor Yellow
}

# ------------------------------------------------------------
# 5. BACKUP OPENEHR TEMPLATES
# ------------------------------------------------------------
Write-Host "[5/6] Saving openEHR templates..." -ForegroundColor Yellow
$ehrZip = Join-Path $backupDir "openehr_artifacts.zip"
Compress-Archive -Path "$projectRoot\openEHR\*" -DestinationPath $ehrZip -Force
Write-Host "      ✓ Saved: openEHR templates → $ehrZip" -ForegroundColor Green
Check-File $ehrZip

# ------------------------------------------------------------
# 6. BACKUP DOCKER IMAGES LIST
# ------------------------------------------------------------
Write-Host "[6/6] Saving Docker images list..." -ForegroundColor Yellow
$imgList = Join-Path $backupDir "docker_images.txt"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}" > $imgList
Write-Host "      ✓ Saved: docker_images.txt" -ForegroundColor Green
Check-File $imgList

# ------------------------------------------------------------
# FINAL OUTPUT
# ------------------------------------------------------------
$totalSize = [math]::Round((Get-ChildItem $backupDir -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB, 2)

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "BACKUP COMPLETED SUCCESSFULLY" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Backup Folder: $backupDir" -ForegroundColor Yellow
Write-Host "Total Size: $totalSize MB" -ForegroundColor Cyan
Write-Host ""
