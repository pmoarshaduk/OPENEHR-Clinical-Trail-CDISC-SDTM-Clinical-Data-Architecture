# File Path: C:\Projects\PCOD\docker\extract.ps1
param(
    [string]$ExportDate = (Get-Date -Format "yyyyMMdd"),
    [string]$OutputPath = "C:\Projects\PCOD\exports\cdisc_sdtm_$ExportDate"
)

# 1. Setup Environment
if (!(Test-Path $OutputPath)) { New-Item -ItemType Directory -Force -Path $OutputPath | Out-Null }
$API_BASE = "http://localhost:8080/ehrbase/rest/openehr/v1"
$TEMPLATE_ID = "PCOD_Working_Impression"

# 2. Extract Data
$aqlBody = @{ q = "SELECT c/uid/value, c/context/start_time/value, c/context/other_context/items[openEHR-EHR-CLUSTER.person.v1]/items[at0001]/value/value, c/context/other_context/items[openEHR-EHR-CLUSTER.person.v1]/items[at0003]/value/value, c/composer/name, c/context/setting/value FROM COMPOSITION c WHERE c/archetype_details/template_id/value = '$TEMPLATE_ID'" } | ConvertTo-Json
$response = Invoke-RestMethod -Uri "$API_BASE/query/aql" -Method POST -ContentType "application/json" -Body $aqlBody
$rows = if ($response.rows) { $response.rows } else { @() }

# 3. Create Patient Map
$patientMap = @{}
$uniqueNhsNumbers = $rows | ForEach-Object { $_[3] } | Select-Object -Unique
for ($i = 0; $i -lt $uniqueNhsNumbers.Count; $i++) { $patientMap[$uniqueNhsNumbers[$i]] = "PCOD-{0:D3}" -f ($i + 1) }

# 4. Generate SDTM Domains
$domains = @("DM", "MH", "CO", "TS")
foreach ($domain in $domains) {
    $domainList = [System.Collections.Generic.List[PSObject]]::new()
    foreach ($row in $rows) {
        $mappedId = $patientMap[$row[3]]
        
        switch ($domain) {
            "DM" { $domainList.Add([PSCustomObject]@{ STUDYID = "PCOD-PILOT-2026"; DOMAIN = "DM"; USUBJID = $mappedId; RFSTDTC = $row[1] }) }
            "MH" { $domainList.Add([PSCustomObject]@{ STUDYID = "PCOD-PILOT-2026"; DOMAIN = "MH"; USUBJID = $mappedId; MHTERM = "Polycystic Ovary Syndrome"; MHSTDTC = $row[1] }) }
            "CO" { $domainList.Add([PSCustomObject]@{ STUDYID = "PCOD-PILOT-2026"; DOMAIN = "CO"; USUBJID = $mappedId; COVAL = "Clinician: $($row[4])"; COREFID = $row[0] }) }
            "TS" { if ($domainList.Count -eq 0) { $domainList.Add([PSCustomObject]@{ STUDYID = "PCOD-PILOT-2026"; DOMAIN = "TS"; TSPARMCD = "TTITLE"; TSVAL = "PCOD Pilot" }) } }
        }
    }
    $domainList | Export-Csv -Path "$OutputPath\PCOD_$($domain)_$ExportDate.csv" -NoTypeInformation -Encoding utf8
}

Write-Host "Success: Extraction complete. Files saved to $OutputPath" -ForegroundColor Green