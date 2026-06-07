# PCOD openEHR CDR Pilot

<div align="center">

[![openEHR](https://img.shields.io/badge/openEHR-Standard-0066CC?style=flat-square)](https://specifications.openehr.org/)
[![EHRbase](https://img.shields.io/badge/EHRbase-2.11.0-28a745?style=flat-square)](https://ehrbase.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16.2-336791?style=flat-square&logo=postgresql)](https://www.postgresql.org/)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=flat-square&logo=docker)](https://www.docker.com/)
[![ICH GCP](https://img.shields.io/badge/ICH_GCP-E6(R2)-dc3545?style=flat-square)](https://www.ich.org/page/efficacy-guidelines)
[![CDISC](https://img.shields.io/badge/CDISC-SDTM_v3.4-ff6600?style=flat-square)](https://www.cdisc.org/standards/foundational/sdtm)
[![Status](https://img.shields.io/badge/Status-Pilot_Live-brightgreen?style=flat-square)]()
[![Template](https://img.shields.io/badge/Template-LOCKED_v1.0-orange?style=flat-square)]()

**A production-grade openEHR Clinical Data Repository (CDR) for a PCOD pilot clinical trial**

**Conceptual G.O.T. Hospital, Bristol, UK**

[Quick Start](#quick-start) · [Architecture](#architecture) · [Data Pipeline](#data-pipeline) · [API Reference](#api-reference) · [Compliance](#compliance) · [Roadmap](#roadmap)

</div>

---

## Table of Contents

- [Project Overview](#project-overview)
- [Project Team](#project-team)
- [Template Lock Notice](#template-lock-notice)
- [Architecture](#architecture)
- [Technical Stack](#technical-stack)
- [Data Flow](#data-flow)
- [Quick Start](#quick-start)
- [Directory Structure](#directory-structure)
- [Data Pipeline](#data-pipeline)
- [API Reference](#api-reference)
- [eCRF Frontend](#ecrf-frontend)
- [Compliance](#compliance)
- [Pilot Data Status](#pilot-data-status)
- [Operations](#operations)
- [Roadmap](#roadmap)
- [Version History](#version-history)
- [References](#references)

---

## Project Overview

This repository documents the full deployment of a **PCOD openEHR Clinical Data Repository (CDR)** pilot. The system enables structured clinical data capture, storage, querying, and regulatory export for a PCOD pilot trial — built on internationally recognised clinical informatics standards.

**What this project delivers:**

- Containerised openEHR CDR using EHRbase 2.11.0 and PostgreSQL 16.2
- Locked clinical template `PCOD_Working_Impression` deployed and validated
- 7 synthetic test patients loaded and verified via AQL
- Electronic Case Report Form (eCRF) — ICH GCP E6(R2) compliant
- Automated CDISC SDTM v3.4 data pipeline (Extract, Validate, Define.xml)
- Full database backup and restore scripts
- Designed for future integration with HAPI FHIR R4, Microsoft Fabric, and Palantir

> **Data notice:** All patient names and *H* numbers in this repository are **entirely synthetic test data**. No real patient data has been used or stored.

---

## Project Team

| Role | Name | Contact |
|------|------|---------|
| **Technical Lead / Architect** | **Muhammad Arshad** | pmoarshaduk@gmail.com |
| Principal Investigator | Dr. Fatima Al-Rashidi | fatima.alrashidi@got-hospital.*H*.uk |
| Clinical Site Lead | Dr. Yusuf Okonkwo | yusuf.okonkwo@got-hospital.*H*.uk |
| Data Manager | Zara Mahmood-Sheikh | zara.mahmood@got-hospital.*H*.uk |
| Regulatory Affairs | Amara Hussain | amara.hussain@got-hospital.*H*.uk |
| CRF Lead | Nadia Khalil | nadia.khalil@got-hospital.*H*.uk |

**Site:** Conceptual G.O.T. Hospital, Bristol, UK

---

## Template Lock Notice

```
+------------------------------------------------------------------+
|  TEMPLATE : PCOD_Working_Impression                              |
|  VERSION  : 1.0.0                                                |
|  STATUS   : LOCKED -- NO FURTHER MODIFICATIONS                   |
|  LOCKED   : 2026-06-06                                           |
|  BY       : Muhammad Arshad (Technical Lead)                     |
|                                                                  |
|  Changes require formal change control per ICH GCP E6(R2)        |
|  Contact  : pmoarshaduk@gmail.com                                |
+------------------------------------------------------------------+
```

**Change control process:** Written request > Impact assessment > Technical review > Approval > Implementation > Validation > Documentation update.

---

## Architecture

```
+-------------------------------------------------------------------------+
|              PCOD openEHR CDR -- System Architecture                    |
+-------------------------------------------------------------------------+
|                                                                         |
|  +-------------------+    +-------------------+    +-----------------+  |
|  |   eCRF (HTML/JS)  |    |  PowerShell Batch  |    |  AQL Queries   |  |
|  |   Patient entry   |    |  load_batch.ps1    |    |  Direct API    |  |
|  +--------+----------+    +--------+----------+    +-------+--------+  |
|           |                        |                        |           |
|           +------------------------+------------------------+           |
|                                    |                                    |
|                                    v                                    |
|            +-----------------------------------------------+            |
|            |     openEHR REST API v1 (EHRbase 2.11.0)      |            |
|            |     http://localhost:8080/ehrbase/rest/        |            |
|            |     openehr/v1/                               |            |
|            |     Swagger UI available                      |            |
|            +------------------+----------------------------+            |
|                               |                                         |
|                               v                                         |
|            +-----------------------------------------------+            |
|            |     EHRbase 2.11.0 (Container: pcod_ehrbase)  |            |
|            |     Template: PCOD_Working_Impression LOCKED  |            |
|            |     Auth: NONE (pilot mode)                   |            |
|            +------------------+----------------------------+            |
|                               |                                         |
|                               v                                         |
|            +-----------------------------------------------+            |
|            |     PostgreSQL 16.2 (Container: pcod_db)      |            |
|            |     Image: ehrbase-v2-postgres:16.2           |            |
|            |     Volume: docker_pcod_db_data (persistent)  |            |
|            +-----------------------------------------------+            |
|                               |                                         |
|                               v                                         |
|            +-----------------------------------------------+            |
|            |     CDISC SDTM Data Pipeline                  |            |
|            |     extract.ps1 > validate-sdtm.ps1 >         |            |
|            |     generate-define-xml.ps1                   |            |
|            |     Output: DM, MH, CO, TS domains            |            |
|            +-----------------------------------------------+            |
|                                                                         |
|  PHASE 2 (Planned)                                                      |
|  HAPI FHIR R4 (Port 8090) <--- openEHR/FHIR mapping                   |
|  Microsoft Fabric / Palantir <--- CDM / FPD ingestion                  |
+-------------------------------------------------------------------------+
```

---

## Technical Stack

| Component | Version | Port | Container | Status |
|-----------|---------|------|-----------|--------|
| EHRbase | 2.11.0 | 8080 | pcod_ehrbase | Running |
| PostgreSQL | ehrbase-v2-postgres:16.2 | 5432 (internal) | pcod_db | Healthy |
| Docker Compose | v2 | — | — | Active |
| openEHR REST API | v1 | 8080 | — | Active |
| Swagger UI | SpringDoc | 8080 | — | Enabled |
| eCRF Frontend | HTML5 / JS | local file | — | Ready |
| HAPI FHIR R4 | — | 8090 (planned) | — | Phase 2 |

> **Note on version history:** EHRbase 2.31.0 was evaluated and rejected. Its compiled `docker-entrypoint` binary hardcodes `spring.profiles.active=docker`, overriding all environment variables and silently disabling the openEHR REST API module. EHRbase 2.11.0 was selected as it uses a standard shell entrypoint and is confirmed working with the full REST API.

---

## Data Flow

```
PHASE 1 -- DATA INGESTION
--------------------------

  Clinician
      |
      v
  eCRF Web Form (Browser)
      |
      | HTTP POST (FLAT JSON)
      v
  openEHR REST API
  POST /ehr                          --> Creates EHR, returns EHR ID in Location header
  POST /ehr/{id}/composition         --> Stores composition (returns 204 No Content)
  ?format=FLAT&templateId=PCOD_Working_Impression
      |
      v
  EHRbase 2.11.0
  Template validation against PCOD_Working_Impression
      |
      v
  PostgreSQL 16.2
  Persistent storage in ehrbase schema


PHASE 2 -- DATA QUERYING
--------------------------

  AQL Query (POST /query/aql)
      |
      v
  EHRbase AQL Engine
      |
      v
  Results (JSON) --> PowerShell / eCRF / Dashboard


PHASE 3 -- CDISC SDTM PIPELINE
--------------------------------

  EHRbase (AQL)
      |
      v
  extract.ps1
  Queries: DM, MH, CO, TS domains
      |
      v
  Raw CSV files (exports/raw_YYYYMMDD/)
  PCOD_DM_*.csv  PCOD_MH_*.csv  PCOD_CO_*.csv  PCOD_TS_*.csv
      |
      v
  validate-sdtm.ps1
  CDISC controlled terminology checks
  Generates: validation_report.txt
      |
      v  (exit 0 = PASSED, exit 1 = FAILED)
  generate-define-xml.ps1
  Generates: define.xml (CDISC Define.xml v2.1)
      |
      v
  Submission package
  Ready for MHRA / FDA / EMA regulatory review


PHASE 4 -- FUTURE (Planned)
-----------------------------

  Validated CSVs
      |
      v
  push-to-fhir.ps1 (planned)
      |
      v
  HAPI FHIR R4 Server (Port 8090)
  Resources: Patient, Condition, Observation
      |
      v
  Microsoft Fabric / Palantir
  CDM / FPD / Analytics
```

---

## Quick Start

### Prerequisites

- Docker Desktop for Windows
- PowerShell 5.1 or later
- 4 GB RAM minimum
- Git

### Clone and Deploy

```powershell
# Clone repository
git clone https://github.com/your-username/pcod-cdr.git
cd pcod-cdr\docker

# Start the stack
docker compose up -d

# Wait for EHRbase to initialise (approx 90 seconds)
Start-Sleep -Seconds 90

# Verify CDR is running -- returns empty array on fresh install
Invoke-RestMethod "http://localhost:8080/ehrbase/rest/openehr/v1/definition/template/adl1.4" -UseBasicParsing
```

### Upload Template

```powershell
Invoke-WebRequest `
  -Uri "http://localhost:8080/ehrbase/rest/openehr/v1/definition/template/adl1.4" `
  -Method POST `
  -ContentType "application/xml" `
  -InFile ".\templates\PCOD_Working_Impression.opt" `
  -UseBasicParsing

# Verify -- should show PCOD_Working_Impression with no leading space
Invoke-RestMethod "http://localhost:8080/ehrbase/rest/openehr/v1/definition/template/adl1.4" -UseBasicParsing
```

### Load a Patient Record

```powershell
# Step 1 -- Create EHR (ID is in Location response header)
$ehr = Invoke-WebRequest `
  -Uri "http://localhost:8080/ehrbase/rest/openehr/v1/ehr" `
  -Method POST -ContentType "application/json" -UseBasicParsing
$ehrId = $ehr.Headers.Location.Split("/")[-1]
Write-Host "EHR ID: $ehrId"

# Step 2 -- Post composition (204 = success)
Invoke-WebRequest `
  -Uri "http://localhost:8080/ehrbase/rest/openehr/v1/ehr/$ehrId/composition?format=FLAT&templateId=PCOD_Working_Impression" `
  -Method POST `
  -Headers @{ "Accept" = "application/json" } `
  -ContentType "application/json" `
  -InFile ".\pcod_record_1_fatima.json" `
  -UseBasicParsing
```

### Load Batch (5 patients)

```powershell
cd C:\Projects\PCOD\docker
.\load_batch.ps1
```

### Verify All Records

```powershell
$aql = @"
{"q":"SELECT e/ehr_id/value AS ehr_id, c/context/other_context[at0001]/items[openEHR-EHR-CLUSTER.person.v1]/items[at0001]/value/value AS name FROM EHR e CONTAINS COMPOSITION c WHERE c/archetype_details/template_id/value = 'PCOD_Working_Impression'"}
"@
Invoke-RestMethod -Uri "http://localhost:8080/ehrbase/rest/openehr/v1/query/aql" `
  -Method POST -ContentType "application/json" -Body $aql -UseBasicParsing | ConvertTo-Json -Depth 5
```

---

## Directory Structure

```
C:\Projects\PCOD\
|
+-- docker\
|   +-- docker-compose.yml              Main stack definition
|   +-- load_batch.ps1                  Batch patient loader
|   +-- backup-all.ps1                  Full backup script
|   +-- extract.ps1                     CDISC AQL extraction
|   +-- validate-sdtm.ps1              SDTM compliance validator
|   +-- generate-define-xml.ps1        Define.xml generator
|   +-- run-pipeline.ps1               Master pipeline orchestrator
|   +-- logs\                           EHRbase runtime logs
|   +-- templates\
|   |   +-- PCOD_Working_Impression.opt LOCKED template
|   +-- backups\                        Database backups (timestamped)
|   +-- ecrf\
|       +-- frontend\
|           +-- index.html              eCRF web form
|
+-- openEHR\
|   +-- templates\                      OPT source files
|   +-- archetypes\                     ADL archetypes
|
+-- exports\
|   +-- raw_YYYYMMDD\                   Extracted CSV files
|   +-- val_YYYYMMDD\                   Validation reports
|   +-- define_YYYYMMDD\               Define.xml output
|
+-- backups\
|   +-- YYYYMMDD_HHMM\
|       +-- db\                         PostgreSQL dump (.sql)
|       +-- config\                     docker-compose, scripts
|       +-- templates\                  OPT files
|       +-- data\                       Patient JSON + AQL snapshot
|
+-- README.md
+-- .gitignore
```

---

## Data Pipeline

### Run the Full Pipeline

```powershell
cd C:\Projects\PCOD\docker
.\run-pipeline.ps1
```

### Pipeline Steps

| Step | Script | Input | Output | Validation |
|------|--------|-------|--------|------------|
| 1. Extract | `extract.ps1` | EHRbase AQL | Raw CSV (DM, MH, CO, TS) | File count check |
| 2. Validate | `validate-sdtm.ps1` | Raw CSV | `validation_report.txt` | exit 0 = PASSED |
| 3. Define.xml | `generate-define-xml.ps1` | Validated CSV | `define.xml` (CDISC v2.1) | File size check |

### CDISC SDTM Domains

| Domain | Description | Source Fields |
|--------|-------------|---------------|
| DM | Demographics | Patient name, *H* number, encounter date |
| MH | Medical History | Clinical presentation, working impression |
| CO | Comments | Clinical notes, consent status |
| TS | Trial Summary | Protocol, site, version metadata |

### Pipeline Expected Output

```
========================================
PCOD Pipeline Started: 20260606
========================================

[Step 1/3] Extracting data...
  Extraction complete: 4 files created

[Step 2/3] Validating SDTM compliance...
  Found 4 CSV files to validate
  Errors: 0  Warnings: 0
  VALIDATION PASSED

[Step 3/3] Generating metadata...
  Define.xml generated: define_20260606\define.xml (1.95 KB)
  Define.xml generated successfully

========================================
PIPELINE SUCCESSFUL
========================================
```

---

## API Reference

### Endpoints

| Purpose | URL | Method | Returns |
|---------|-----|--------|---------|
| Swagger UI | `http://localhost:8080/ehrbase/swagger-ui/index.html` | GET | Interactive docs |
| List templates | `http://localhost:8080/ehrbase/rest/openehr/v1/definition/template/adl1.4` | GET | Template list |
| Upload template | `http://localhost:8080/ehrbase/rest/openehr/v1/definition/template/adl1.4` | POST | 201 Created |
| Create EHR | `http://localhost:8080/ehrbase/rest/openehr/v1/ehr` | POST | 201, EHR ID in Location header |
| Post composition | `http://localhost:8080/ehrbase/rest/openehr/v1/ehr/{id}/composition?format=FLAT&templateId=PCOD_Working_Impression` | POST | 204 No Content |
| AQL query | `http://localhost:8080/ehrbase/rest/openehr/v1/query/aql` | POST | JSON result set |

### Key API Behaviours (EHRbase 2.11.0)

- `/system/info` does **not** exist in 2.11.0 -- use `/definition/template/adl1.4` to verify CDR is alive
- EHR ID is returned in the **Location response header**, not the body
- Composition POST returns **204 No Content** on success (not 200 or 201)
- Format parameter must be uppercase: `format=FLAT` (not `flat`)
- Template ID must be passed as query parameter: `templateId=PCOD_Working_Impression`
- `openEHR-TEMPLATE-ID` header is silently dropped by PowerShell -- use query param instead

### AQL Path Reference

| Field | AQL Path |
|-------|----------|
| EHR ID | `e/ehr_id/value` |
| Composition ID | `c/uid/value` |
| Encounter date | `c/context/start_time/value` |
| Composer / Clinician | `c/composer/name` |
| Facility | `c/context/health_care_facility/name` |
| Patient name | `c/context/other_context[at0001]/items[openEHR-EHR-CLUSTER.person.v1]/items[at0001]/value/value` |
| *H* number | `c/context/other_context[at0001]/items[openEHR-EHR-CLUSTER.person.v1]/items[at0003,'*H* Number']/value/value` |

### FLAT JSON Payload (working format)

```json
{
  "ctx/language": "en",
  "ctx/territory": "GB",
  "ctx/composer_name": "Dr. Fatima Al-Rashidi (PI)",
  "ctx/time": "2026-06-06T09:00:00.000Z",
  "ctx/health_care_facility|name": "Conceptual G.O.T. Hospital, Bristol",
  "ctx/health_care_facility|id": "GOT-BRS-001",
  "pcod_working_impression/context/person:0/name|value": "Patient Name",
  "pcod_working_impression/context/person:0/*H*_number|value": "1234567890"
}
```

---

## eCRF Frontend

The eCRF (`ecrf/frontend/index.html`) is a standalone HTML5 form with built-in validation and CDR submission.

### Form Sections

| Section | Content | Stored in CDR |
|---------|---------|---------------|
| A | Consent and eligibility checkboxes | No |
| B | Patient name and *H* number | **Yes** |
| C | Demographics (DOB, sex, ethnicity, postcode) | No -- DP |
| D | Clinical presentation, BMI, cycle regularity, notes | No -- DP |
| E | Encounter date, clinician, facility, setting | **Yes** |
| F | Audit trail (ALCOA+) | No |

`DP` = Display only. Planned for CDR template v2.0.

### Validation Rules

- Submit button disabled until: both consent checkboxes ticked + patient name (min 2 chars) + valid 10-digit *H* number + clinician selected
- *H* number field strips non-numeric characters automatically
- Success banner persists until dismissed by user (X button)
- Form auto-resets after successful submission
- Record count in status bar refreshes after each submission

---

## Compliance

| Standard | Version | Status | Scope |
|----------|---------|--------|-------|
| ICH GCP E6(R2) | Current | Implemented | ALCOA+, audit trails, change control |
| UK GDPR / DPA 2018 | 2018 | Compliant (synthetic data pilot) | Data protection, pseudonymisation |
| CDISC SDTM | v3.4 | Implemented | DM, MH, CO, TS domains |
| openEHR International | v1.0.4 | Core architecture | CDR, templates, AQL |
| *H* Digital Standards | Current | Applied | *H* number format, SNOMED CT |
| DCB0129 / DCB0160 | Current | Planned Phase 2 | Clinical safety |
| 21 CFR Part 11 | Current | Planned Phase 2 | Electronic records |
| FHIR R4 | 4.0.1 | Planned Phase 2 | Interoperability |

---

## Pilot Data Status

| Patient (Synthetic) | *H* Number | Date Loaded | EHR Status |
|---------------------|------------|-------------|------------|
| Fatima Al-Hassan | 4857291036 | 2026-06-05 | Active |
| Priya Sharma | 7623940182 | 2026-06-05 | Active |
| Amara Okonkwo | 3421876590 | 2026-06-05 | Active |
| Zara Mahmood | 6178234905 | 2026-06-05 | Active |
| Divya Nair | 9034521678 | 2026-06-05 | Active |
| Kefilwe Dlamini | 5289013746 | 2026-06-05 | Active |
| Rania Al-Farsi | 7890123456 | 2026-06-05 | Active |

**Total: 7 synthetic patients. No real patient data.**

---

## Operations

### Daily Commands

```powershell
# Start CDR
cd C:\Projects\PCOD\docker
docker compose up -d

# Stop CDR
docker compose down

# Live logs
docker logs pcod_ehrbase -f

# Container status
docker compose ps

# Verify CDR alive
Invoke-RestMethod "http://localhost:8080/ehrbase/rest/openehr/v1/definition/template/adl1.4" -UseBasicParsing
```

### Backup

```powershell
cd C:\Projects\PCOD\docker
.\backup-all.ps1
```

Backup saves to `backups\YYYYMMDD_HHMM\` containing:
- PostgreSQL full dump (`.sql`)
- `docker-compose.yml` and all scripts
- Template `.opt` files
- Patient JSON files
- Live AQL snapshot as JSON and CSV

### Restore from Backup

```powershell
# Wipe and restart fresh
docker compose down
docker volume rm docker_pcod_db_data
docker compose up -d
Start-Sleep -Seconds 90

# Restore database
docker exec -i pcod_db psql -U postgres -d ehrbase `
  < ".\backups\YYYYMMDD_HHMM\db\ehrbase_full_YYYYMMDD_HHMM.sql"
```

### Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Password auth failed | Stale volume with old credentials | `docker volume rm docker_pcod_db_data` then restart |
| Template not found (500) | `openEHR-TEMPLATE-ID` header dropped by PowerShell | Use `?templateId=` query parameter instead |
| 406 Not Acceptable | Wrong format case | Use `format=FLAT` (uppercase) |
| 204 on composition POST | This is correct -- success | No action needed |
| `/system/info` returns 404 | Endpoint does not exist in 2.11.0 | Use `/definition/template/adl1.4` to verify CDR |
| Docker passwords garbled | Special chars `$` or `!` in passwords | Remove `$` and `!` from all password values in compose file |

---

## Roadmap

### Phase 1 -- Pilot (Complete)

- [x] EHRbase 2.11.0 on Docker with PostgreSQL 16.2
- [x] openEHR REST API fully operational
- [x] `PCOD_Working_Impression` template loaded and locked
- [x] Leading space defect in template fixed and reloaded
- [x] 7 synthetic patients loaded and verified via AQL
- [x] Batch load script (`load_batch.ps1`)
- [x] Full backup and restore script (`backup-all.ps1`)
- [x] eCRF frontend -- GCP/ICH E6(R2) compliant
- [x] CDISC SDTM pipeline (extract, validate, define.xml)
- [x] Swagger UI enabled

### Phase 2 -- Interoperability (Planned)

- [ ] HAPI FHIR R4 server (port 8090, Docker, no conflict with EHRbase)
- [ ] `push-to-fhir.ps1` -- openEHR to FHIR R4 resource mapping
- [ ] RBAC authentication (Basic Auth, then OAuth2)
- [ ] Microsoft Fabric / Palantir CDM ingestion
- [ ] Template v2.0 with clinical archetypes (EVALUATION.problem_diagnosis.v1, ACTION.informed_consent.v0)

### Phase 3 -- Scale (Future)

- [ ] Multi-site support (3 sites)
- [ ] 21 CFR Part 11 audit trails
- [ ] 100-patient rehearsal load test
- [ ] Clinical trial protocol integration
- [ ] DCB0129 / DCB0160 clinical safety case
- [ ] *H* DSPT v5.0 alignment

---

## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | 2026-06-05 | Muhammad Arshad | Initial CDR deployment, template loaded |
| 1.0.1 | 2026-06-05 | Muhammad Arshad | Template leading space defect fixed and reloaded |
| 1.0.2 | 2026-06-06 | Muhammad Arshad | CDISC SDTM pipeline operational (DM, MH, CO, TS) |
| 1.0.3 | 2026-06-06 | Muhammad Arshad | eCRF frontend updated (GCP/ICH E6 R2 compliant) |
| 1.0.4 | 2026-06-06 | Muhammad Arshad | Full backup script, README, pipeline v2.2.0 |

---

## References

| Standard / Resource | URL |
|---------------------|-----|
| ICH GCP E6(R2) | https://www.ich.org/page/efficacy-guidelines |
| UK GDPR / ICO Guide | https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/ |
| CDISC SDTM v3.4 | https://www.cdisc.org/standards/foundational/sdtm |
| openEHR Specification | https://specifications.openehr.org/ |
| openEHR CKM | https://ckm.openehr.org/ckm/ |
| EHRbase Documentation | https://ehrbase.org/documentation/ |
| *H* Digital Standards | https://digital.*H*.uk/data-and-information |
| SNOMED CT UK | https://isd.digital.*H*.uk/trud/ |
| DCB0129 / DCB0160 | https://digital.*H*.uk/services/clinical-safety |

---

## Licence and Disclaimer

This project is released for **educational and research purposes only**.

All patient names, *H* numbers, and clinical data are **entirely synthetic**.
No real patient data has been used, processed, or stored.

Clinical deployment requires full regulatory approval, DPIA completion,
clinical safety case (DCB0129/DCB0160), appropriate *H* IG agreements,
and authentication implementation before handling real patient data.

---

<div align="center">

**Muhammad Arshad** | Technical Lead
pmoarshaduk@gmail.com
Conceptual G.O.T. Hospital, Bristol, UK

*Built with openEHR · EHRbase 2.11.0 · PostgreSQL 16.2 · Docker*

*ICH GCP E6(R2) | UK GDPR | CDISC SDTM v3.4 | *H* Digital Standards*

</div>
