Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "VERIFYING SERVICES" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

# Test EHRbase
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/ehrbase/" -UseBasicParsing -TimeoutSec 5
    Write-Host "✅ EHRbase: ONLINE (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "❌ EHRbase: OFFLINE - $($_.Exception.Message)" -ForegroundColor Red
}

# Test Template endpoint
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/ehrbase/rest/openehr/v1/definition/template/adl1.4/PCOD_Working_Impression" -UseBasicParsing -TimeoutSec 5
    Write-Host "✅ Template: LOADED (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "❌ Template: NOT FOUND - $($_.Exception.Message)" -ForegroundColor Red
}

# Test eCRF proxy
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5500/api/definition/template/adl1.4/PCOD_Working_Impression" -UseBasicParsing -TimeoutSec 5
    Write-Host "✅ eCRF Proxy: WORKING (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "❌ eCRF Proxy: FAILED - $($_.Exception.Message)" -ForegroundColor Red
}

# Test eCRF Web
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5500" -UseBasicParsing -TimeoutSec 5
    Write-Host "✅ eCRF Web: ACCESSIBLE (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "❌ eCRF Web: NOT ACCESSIBLE - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""