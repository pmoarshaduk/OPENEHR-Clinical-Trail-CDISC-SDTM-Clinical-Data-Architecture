# ============================================================
# PCOD CDR MASTER PIPELINE
# Orchestrates: Extract -> Validate -> Define.xml Generation
# Version: 2.2.0 (Production Ready)
# ============================================================

# Hard-coded paths for simplicity
$BaseDir = "C:\Projects\PCOD"
$DockerDir = "C:\Projects\PCOD\docker"
$ExportDir = "C:\Projects\PCOD\exports"
$DateTag = Get-Date -Format "yyyyMMdd"

# Ensure output structure exists
if (!(Test-Path $ExportDir)) { 
    New-Item -ItemType Directory -Path $ExportDir -Force | Out-Null
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PCOD Pipeline Started: $DateTag" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# 1. EXTRACT
# ============================================================
Write-Host "[Step 1/3] Extracting data..." -ForegroundColor Yellow

$RawPath = "$ExportDir\raw_$DateTag"
New-Item -ItemType Directory -Force -Path $RawPath | Out-Null

& "$DockerDir\extract.ps1" -ExportDate $DateTag -OutputPath $RawPath 2>&1 | Out-Null

# Check if files were created
$csvFiles = Get-ChildItem -Path $RawPath -Filter "*.csv" -ErrorAction SilentlyContinue
if ($csvFiles.Count -eq 0) {
    Write-Host "  ✗ Extraction FAILED - No CSV files created" -ForegroundColor Red
    exit 1
}

Write-Host "  ✓ Extraction complete: $($csvFiles.Count) files created" -ForegroundColor Green

# ============================================================
# 2. VALIDATE
# ============================================================
Write-Host ""
Write-Host "[Step 2/3] Validating SDTM compliance..." -ForegroundColor Yellow

$ValidationPath = "$ExportDir\val_$DateTag"
New-Item -ItemType Directory -Force -Path $ValidationPath | Out-Null

$validateScript = "$DockerDir\validate-sdtm.ps1"
if (-not (Test-Path $validateScript)) {
    Write-Host "  ✗ Validation script not found: $validateScript" -ForegroundColor Red
    exit 1
}

# Run validation and capture exit code
& $validateScript -ExportPath $RawPath -ValidationReportPath $ValidationPath
$validateExitCode = $LASTEXITCODE

# Determine validation result
if ($validateExitCode -eq 0) {
    Write-Host "  ✓ Validation PASSED" -ForegroundColor Green
} else {
    Write-Host "  ✗ Validation FAILED with exit code $validateExitCode" -ForegroundColor Red
    exit 1
}

# ============================================================
# 3. DEFINE.XML
# ============================================================
Write-Host ""
Write-Host "[Step 3/3] Generating metadata..." -ForegroundColor Yellow

$DefinePath = "$ExportDir\define_$DateTag"
New-Item -ItemType Directory -Force -Path $DefinePath | Out-Null

$defineScript = "$DockerDir\generate-define-xml.ps1"
if (Test-Path $defineScript) {
    & $defineScript -SourcePath $RawPath -OutputPath $DefinePath
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Define.xml generated successfully" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Define.xml generation had issues (exit code: $LASTEXITCODE)" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ⚠ Define.xml script not found: $defineScript" -ForegroundColor Yellow
}

# ============================================================
# SUMMARY
# ============================================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "PIPELINE SUCCESSFUL" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Raw Data:      $RawPath" -ForegroundColor Gray
Write-Host "Validation:    $ValidationPath" -ForegroundColor Gray
if (Test-Path "$DefinePath\define.xml") {
    Write-Host "Define.xml:    $DefinePath\define.xml" -ForegroundColor Gray
}
Write-Host "Total CSV Files: $($csvFiles.Count)" -ForegroundColor Gray
Write-Host ""
