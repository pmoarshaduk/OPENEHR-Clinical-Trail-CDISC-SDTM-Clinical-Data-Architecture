# ============================================================
# PCOD CDR — Batch Load 5 Synthetic Patients
# Run from: C:\Projects\PCOD\docker
# ============================================================

$baseUrl  = "http://localhost:8080/ehrbase/rest/openehr/v1"
$template = "PCOD_Working_Impression"

$patients = @(
    @{ file="pcod_patient_01.json"; name="Amara Okonkwo"   },
    @{ file="pcod_patient_02.json"; name="Zara Mahmood"    },
    @{ file="pcod_patient_03.json"; name="Divya Nair"      },
    @{ file="pcod_patient_04.json"; name="Kefilwe Dlamini" },
    @{ file="pcod_patient_05.json"; name="Rania Al-Farsi"  }
)

$results = @()

foreach ($p in $patients) {

    Write-Host ""
    Write-Host "Loading: $($p.name)" -ForegroundColor Cyan

    # Step 1 — Create EHR
    try {
        $ehrResp = Invoke-WebRequest `
            -Uri "$baseUrl/ehr" `
            -Method POST `
            -ContentType "application/json" `
            -UseBasicParsing -ErrorAction Stop

        $ehrId = $ehrResp.Headers.Location.Split("/")[-1]
        Write-Host "  EHR ID : $ehrId" -ForegroundColor Gray

    } catch {
        Write-Host "  FAILED to create EHR: $_" -ForegroundColor Red
        continue
    }

    # Step 2 — Post composition
    try {
        $compResp = Invoke-WebRequest `
            -Uri "$baseUrl/ehr/$ehrId/composition?format=FLAT&templateId=$template" `
            -Method POST `
            -Headers @{ "Accept" = "application/json" } `
            -ContentType "application/json" `
            -InFile ".\$($p.file)" `
            -UseBasicParsing -ErrorAction Stop

        Write-Host "  Status : $($compResp.StatusCode) — SAVED" -ForegroundColor Green
        $results += [PSCustomObject]@{ Name=$p.name; EHR_ID=$ehrId; Status="OK" }

    } catch {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $reader.BaseStream.Position = 0
        $errBody = $reader.ReadToEnd()
        Write-Host "  FAILED : $errBody" -ForegroundColor Red
        $results += [PSCustomObject]@{ Name=$p.name; EHR_ID=$ehrId; Status="FAILED" }
    }
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  BATCH LOAD SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
$results | Format-Table -AutoSize
