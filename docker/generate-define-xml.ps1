# ============================================================
# PCOD CDR - Define.xml Generator
# Generates CDISC Define.xml from validated CSV files
# Author: Muhammad Arshad
# ============================================================

param(
    [string]$SourcePath,
    [string]$OutputPath
)

# Ensure output directory exists
New-Item -ItemType Directory -Force -Path $OutputPath | Out-Null

Write-Host "Generating Define.xml from: $SourcePath" -ForegroundColor Yellow

# Find CSV files
$csvFiles = Get-ChildItem -Path $SourcePath -Filter "*.csv"

if ($csvFiles.Count -eq 0) {
    Write-Host "  ERROR: No CSV files found in $SourcePath" -ForegroundColor Red
    exit 1
}

Write-Host "  Found $($csvFiles.Count) CSV files" -ForegroundColor Gray

# Define.xml file path
$defineXmlPath = "$OutputPath\define.xml"

# Start building XML
$xmlContent = @'
<?xml version="1.0" encoding="UTF-8"?>
<Define xmlns="http://www.cdisc.org/ns/define/v2.1"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.cdisc.org/ns/define/v2.1 define2-1.xsd"
        ODMVersion="1.3.2"
        FileOID="PCOD.PILOT.DEFINE"
        CreationDateTime="' + (Get-Date -Format "yyyy-MM-ddTHH:mm:ss") + '">

    <Study OID="PCOD.PILOT">
        <GlobalVariables>
            <StudyName>PCOD Working Impression Pilot Study</StudyName>
            <StudyDescription>Electronic Case Report Form data for PCOD pilot trial</StudyDescription>
            <ProtocolName>PCOD-PILOT-2026-v1.0</ProtocolName>
        </GlobalVariables>
        <BasicDefinitions>
            <MeasurementUnit OID="UNIT.DAYS" Name="Days"/>
            <MeasurementUnit OID="UNIT.YEARS" Name="Years"/>
        </BasicDefinitions>
    </Study>

    <MetaDataVersion OID="MDV.PCOD.001" Name="PCOD SDTM Metadata" Description="SDTM v3.4 compliant metadata">

'@

# Add ItemGroupDef for each domain
foreach ($file in $csvFiles) {
    $domain = ($file.BaseName -split "_")[1]
    $xmlContent += @"
        <ItemGroupDef OID="$domain" Name="$domain Domain" Repeating="Yes" SASDatasetName="$domain" Domain="$domain">
            <Description>
                <TranslatedText>$domain Domain</TranslatedText>
            </Description>
        </ItemGroupDef>

"@
}

$xmlContent += @'
    </MetaDataVersion>
</Define>
'@

# Save define.xml
$xmlContent | Out-File -FilePath $defineXmlPath -Encoding utf8

Write-Host "  ✓ Define.xml generated: $defineXmlPath" -ForegroundColor Green
Write-Host "  File size: $([math]::Round((Get-Item $defineXmlPath).Length/1KB, 2)) KB" -ForegroundColor Gray

exit 0