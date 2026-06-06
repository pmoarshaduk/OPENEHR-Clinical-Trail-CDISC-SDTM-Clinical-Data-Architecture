# PCOD Clinical Trial — EHRbase CDR

## Stack
| Component | Version |
|---|---|
| EHRbase | 2.11.0 |
| PostgreSQL | ehrbase-v2-postgres:16.2 |
| Auth | NONE (secured laptop) |

## Directory Structure
```
C:\Projects\PCOD\docker\
├── docker-compose.yml      ← main compose file
├── setup.ps1               ← one-time setup script
├── logs\                   ← EHRbase runtime logs
├── templates\              ← store your .opt files here
└── backups\                ← manual DB backups
```

## Endpoints
| Purpose | URL |
|---|---|
| REST API base | http://localhost:8080/ehrbase/rest/openehr/v1/ |
| System info | http://localhost:8080/ehrbase/rest/openehr/v1/system/info |
| Templates | http://localhost:8080/ehrbase/rest/openehr/v1/definition/template/adl1.4 |
| Swagger UI | http://localhost:8080/ehrbase/swagger-ui/index.html |

## First-Time Setup
```powershell
cd C:\Projects\PCOD\docker
.\setup.ps1
```

## Daily Use
```powershell
# Start
docker compose up -d

# Stop
docker compose down

# Logs
docker logs pcod_ehrbase -f

# Status
docker compose ps
```

## Upload a Template
```powershell
Invoke-WebRequest `
  -Uri "http://localhost:8080/ehrbase/rest/openehr/v1/definition/template/adl1.4" `
  -Method POST `
  -ContentType "application/xml" `
  -InFile ".\templates\YourTemplate.opt"
```

## Create an EHR
```powershell
Invoke-RestMethod `
  -Uri "http://localhost:8080/ehrbase/rest/openehr/v1/ehr" `
  -Method POST `
  -ContentType "application/json"
```

## Backup Database
```powershell
docker exec pcod_db pg_dump -U postgres ehrbase > .\backups\ehrbase_$(Get-Date -Format 'yyyyMMdd_HHmm').sql
```
