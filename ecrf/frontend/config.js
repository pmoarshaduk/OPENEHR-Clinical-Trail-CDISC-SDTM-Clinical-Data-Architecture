// PCOD eCRF Configuration File
// Version: v1.0.0
// Last Updated: 2026-06-06

window.PCOD_CONFIG = {
    // API Configuration
    API_BASE: "http://localhost:8080/ehrbase/rest/openehr/v1",
    TEMPLATE_ID: "PCOD_Working_Impression",
    
    // Site Configuration
    SITE_ID: "GOT-HOSP-001",
    SITE_NAME: "Conceptual G.O.T. Hospital, Bristol, UK",
    SITE_COUNTRY: "GB",
    
    // Clinical Configuration
    DEFAULT_SNOMED_CODE: "237055004",
    DEFAULT_SNOMED_TERM: "Polycystic Ovary Syndrome",
    DEFAULT_TERMINOLOGY: "SNOMED CT",
    
    // Compliance Standards
    COMPLIANCE: {
        ICH_GCP: "E6(R2)",
        CDISC: "SDTM v3.4",
        NHS_DIGITAL: "DCB0129/DCB0160",
        GDPR: "UK GDPR Article 32"
    },
    
    // Version
    VERSION: "v1.0.0",
    TEMPLATE_LOCKED: true,
    
    // Contact
    CONTACT: {
        TECHNICAL_LEAD: "Muhammad Arshad",
        EMAIL: "pmoarshaduk@gmail.com"
    }
};

console.log("PCOD eCRF Config Loaded v1.0.0");