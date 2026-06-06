# ============================================================
# PCOD CDR — Full Setup Script
# Run from: C:\Projects\PCOD\docker
# ============================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PCOD CDR Setup — EHRbase 2.11.0" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ----------------------------------------------------------
# STEP 1 — Stop and remove ALL previous containers
# ----------------------------------------------------------
Write-Host "[1/6] Stopping and removing old containers..." -ForegroundColor Yellow

$oldContainers = @("pcod_ehrbase", "pcod_postgres", "pcod_db", "ehrbase_cdr_prod", "ehrbase_db_prod")
foreach ($c in $oldContainers) {
    $exists = docker ps -a --format "{{.Names}}" | Select-String $c
    if ($exists) {
        docker stop $c 2>$null
        docker rm $c 2>$null
        Write-Host "  Removed: $c" -ForegroundColor Gray
    }
}

# ----------------------------------------------------------
# STEP 2 — Remove old C:\Projects\ehrbase if it exists
# ----------------------------------------------------------
Write-Host "[2/6] Removing old C:\Projects\ehrbase directory..." -ForegroundColor Yellow
if (Test-Path "C:\Projects\ehrbase") {
    Remove-Item -Recurse -Force "C:\Projects\ehrbase"
    Write-Host "  Removed C:\Projects\ehrbase" -ForegroundColor Gray
} else {
    Write-Host "  Not found — skipping" -ForegroundColor Gray
}

# ----------------------------------------------------------
# STEP 3 — Build clean directory structure under C:\Projects\PCOD\docker
# ----------------------------------------------------------
Write-Host "[3/6] Creating clean directory structure..." -ForegroundColor Yellow

$base = "C:\Projects\PCOD\docker"
$dirs = @(
    "$base\logs",
    "$base\templates",
    "$base\backups"
)
foreach ($d in $dirs) {
    if (-not (Test-Path $d)) {
        New-Item -ItemType Directory -Path $d -Force | Out-Null
        Write-Host "  Created: $d" -ForegroundColor Gray
    } else {
        Write-Host "  Exists:  $d" -ForegroundColor Gray
    }
}

# ----------------------------------------------------------
# STEP 4 — Wipe old postgres data volume
# ----------------------------------------------------------
Write-Host "[4/6] Removing old postgres data volume..." -ForegroundColor Yellow
docker volume rm pcod_db_data 2>$null
docker volume rm pcod_postgres_data 2>$null

# Also wipe bind-mount folder if it exists
if (Test-Path "$base\postgres") {
    Remove-Item -Recurse -Force "$base\postgres"
    Write-Host "  Removed old postgres bind-mount folder" -ForegroundColor Gray
}
Write-Host "  Volume wiped — fresh database will be created" -ForegroundColor Gray

# ----------------------------------------------------------
# STEP 5 — Start services
# ----------------------------------------------------------
Write-Host "[5/6] Starting PCOD CDR (EHRbase 2.11.0)..." -ForegroundColor Yellow
Set-Location $base
docker compose up -d

Write-Host ""
Write-Host "  Waiting 90 seconds for EHRbase to fully start..." -ForegroundColor Gray
Start-Sleep -Seconds 90

# ----------------------------------------------------------
# STEP 6 — Verify
# ----------------------------------------------------------
Write-Host "[6/6] Verifying REST API..." -ForegroundColor Yellow
Write-Host ""

try {
    $info = Invoke-RestMethod "http://localhost:8080/ehrbase/rest/openehr/v1/system/info" -ErrorAction Stop
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  CDR IS UP AND RUNNING!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  System ID : $($info.system_id)" -ForegroundColor White
    Write-Host "  Version   : $($info.description)" -ForegroundColor White
    Write-Host ""
    Write-Host "  REST API  : http://localhost:8080/ehrbase/rest/openehr/v1/" -ForegroundColor Cyan
    Write-Host "  Swagger   : http://localhost:8080/ehrbase/swagger-ui/index.html" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "  REST API not responding yet." -ForegroundColor Red
    Write-Host "  Check logs: docker logs pcod_ehrbase" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Last 20 log lines:" -ForegroundColor Yellow
    docker logs pcod_ehrbase --tail 20
}
