# Simple batch script using your existing JSON structure
$BaseUrl = "http://localhost:8080"

# List of patients to add
$patients = @(
    @{
        name = "Divya Menon"
        nhs = "9988776655"
    },
    @{
        name = "Lakshmi Nair" 
        nhs = "8877665544"
    },
    @{
        name = "Anjali Desai"
        nhs = "7766554433"
    }
)

foreach ($patient in $patients) {
    Write-Host "Creating record for: $($patient.name)" -ForegroundColor Yellow
    
    # Create EHR
    $ehrResp = Invoke-WebRequest -Uri "$BaseUrl/ehrbase/rest/openehr/v1/ehr" -Method POST -ContentType "application/json" -UseBasicParsing
    $ehrId = $ehrResp.Headers.Location.Split("/")[-1]
    
    # Create composition JSON
    $jsonContent = @"
{
  "ctx/language": "en",
  "ctx/territory": "GB",
  "ctx/composer_name": "Dr. Aisha Patel",
  "ctx/id_scheme": "NHS",
  "ctx/id_namespace": "NHS",
  "ctx/time": "$(Get-Date -Format 'yyyy-MM-ddTHH:mm:ss.000Z')",
  "ctx/health_care_facility|name": "PCOD Trial Centre London",
  "ctx/health_care_facility|id": "PCOD-TCL-001",
  "pcod_working_impression/context/person:0/name|value": "$($patient.name)",
  "pcod_working_impression/context/person:0/nhs_number|value": "$($patient.nhs)",
  "pcod_working_impression/problem_diagnosis_name|value": "Polycystic Ovary Syndrome",
  "pcod_working_impression/problem_diagnosis_name|code": "237055004",
  "pcod_working_impression/problem_diagnosis_name|terminology": "SNOMED CT",
  "pcod_working_impression/consent_status": true
}
"@
    
    # Save to temp file
    $tempFile = "C:\temp\record_$($patient.name).json"
    $jsonContent | Out-File -FilePath $tempFile -Encoding utf8
    
    # Upload
    $composeUrl = "$BaseUrl/ehrbase/rest/openehr/v1/ehr/$ehrId/composition?format=FLAT&templateId=PCOD_Working_Impression"
    $response = Invoke-WebRequest -Uri $composeUrl -Method POST -Headers @{"Accept"="application/json"} -ContentType "application/json" -InFile $tempFile -UseBasicParsing
    
    Write-Host "  Created: EHR=$ehrId, Status=$($response.StatusCode)" -ForegroundColor Green
    
    # Cleanup
    Remove-Item $tempFile
}

Write-Host "Batch complete!" -ForegroundColor Green