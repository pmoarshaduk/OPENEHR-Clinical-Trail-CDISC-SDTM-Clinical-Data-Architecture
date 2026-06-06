# ============================================================
# PCOD CDR - SDTM Pre-validator
# Validates exported CSVs against CDISC rules
# Author: Muhammad Arshad
# ============================================================

param(
    [string]$ExportPath,
    [string]$ValidationReportPath
)

# Create validation output directory
New-Item -ItemType Directory -Force -Path $ValidationReportPath | Out-Null

Write-Host "Validating SDTM compliance for: $ExportPath" -ForegroundColor Yellow

# Find CSV files
$csvFiles = Get-ChildItem -Path $ExportPath -Filter "*.csv"

if ($csvFiles.Count -eq 0) {
    Write-Host "  ERROR: No CSV files found in $ExportPath" -ForegroundColor Red
    exit 1
}

Write-Host "  Found $($csvFiles.Count) CSV files to validate" -ForegroundColor Gray

# Validation results
$allErrors = @()
$allWarnings = @()

# Define CDISC controlled terminology
$validSEX = @("M", "F", "U")
$validMHPRES = @("Y", "N")
$validMHSTATUS = @("ACTIVE", "COMPLETED", "ONGOING")
$validCOEVAL = @("COMPLETED", "PENDING", "ONGOING")

# Validate each domain
foreach ($file in $csvFiles) {
    $domain = ($file.BaseName -split "_")[1]
    Write-Host "  Validating domain: $domain" -ForegroundColor Gray
    
    $data = Import-Csv -Path $file.FullName
    $rowNum = 1
    
    foreach ($row in $data) {
        # DM Domain Validation
        if ($domain -eq "DM") {
            $sexValue = $row.SEX
            if ($sexValue -and $sexValue.Trim() -notin $validSEX) {
                $errMsg = "DM Row " + $rowNum + ": SEX='" + $sexValue + "' - Must be M, F, or U"
                $allErrors += $errMsg
            }
        }
        
        # MH Domain Validation
        if ($domain -eq "MH") {
            $mhpresValue = $row.MHPRES
            if ($mhpresValue -and $mhpresValue.Trim() -notin $validMHPRES) {
                $errMsg = "MH Row " + $rowNum + ": MHPRES='" + $mhpresValue + "' - Must be Y or N"
                $allErrors += $errMsg
            }
            
            $mhstatusValue = $row.MHSTATUS
            if ($mhstatusValue -and $mhstatusValue.Trim() -notin $validMHSTATUS) {
                $warnMsg = "MH Row " + $rowNum + ": MHSTATUS='" + $mhstatusValue + "' - Recommended values: ACTIVE, COMPLETED, ONGOING"
                $allWarnings += $warnMsg
            }
        }
        
        # CO Domain Validation
        if ($domain -eq "CO") {
            $coevalValue = $row.CＯEVAL
            if ($coevalValue -and $coevalValue.Trim() -notin $validCOEVAL) {
                $warnMsg = "CO Row " + $rowNum + ": COEVAL='" + $coevalValue + "' - Recommended values: COMPLETED, PENDING, ONGOING"
                $allWarnings += $warnMsg
            }
        }
        
        $rowNum++
    }
}

# Generate validation report
$reportPath = "$ValidationReportPath\validation_report.txt"

$reportContent = @"
╔═══════════════════════════════════════════════════════════════════════════════╗
║                         SDTM PRE-VALIDATION REPORT                            ║
╚═══════════════════════════════════════════════════════════════════════════════╝

Validation Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Export Path: $ExportPath
Files Validated: $($csvFiles.Count)

SUMMARY
=======
Total Errors: $($allErrors.Count)
Total Warnings: $($allWarnings.Count)

ERRORS (Must Fix)
=================
$(if ($allErrors.Count -eq 0) { "  No errors found." } else { $allErrors -join "`n" })

WARNINGS (Review)
=================
$(if ($allWarnings.Count -eq 0) { "  No warnings found." } else { $allWarnings -join "`n" })

STATUS: $(if ($allErrors.Count -eq 0) { "PASSED" } else { "FAILED" })
"@

$reportContent | Out-File -FilePath $reportPath -Encoding utf8

Write-Host ""
Write-Host "Validation Report: $reportPath" -ForegroundColor Cyan
Write-Host "Errors: $($allErrors.Count)" -ForegroundColor $(if ($allErrors.Count -eq 0) { "Green" } else { "Red" })
Write-Host "Warnings: $($allWarnings.Count)" -ForegroundColor Yellow

if ($allErrors.Count -eq 0) {
    Write-Host "✓ VALIDATION PASSED" -ForegroundColor Green
    exit 0
} else {
    Write-Host "✗ VALIDATION FAILED" -ForegroundColor Red
    exit 1
}
