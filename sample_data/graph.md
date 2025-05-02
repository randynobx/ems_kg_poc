# NFIRS 5.0 EMS Module Knowledge Graph Schema Documentation

## Node Types

### 1. Incident
**Description:** Represents a unique EMS incident as recorded in NFIRS.  
**Fields:**  
- `INCIDENT_KEY`: Incident key  
- `STATE`: State  
- `FDID`: Fire Department ID  
- `INC_DATE`: Incident date  
- `INC_NO`: Incident number  
- `EXP_NO`: Exposure number  
- `VERSION`: Version

---

### 2. Patient
**Description:** Represents an individual patient involved in an EMS incident.  
**Fields:**  
- `PATIENT_NO`: Patient number  
- `AGE`: Age  
- `GENDER`: Gender  
- `RACE`: Race  
- `ETH_EMS`: Ethnicity EMS  
- `PAT_STATUS`: Patient status

---

### 3. EMSResponse
**Description:** Captures the EMS response details for an incident.  
**Fields:**  
- `ARRIVAL`: Arrival status  
- `TRANSPORT`: Transport status  
- `PROVIDER_A`: Provider A  
- `EMS_DISPO`: EMS disposition

---

### 4. ClinicalDetails
**Description:** Contains clinical information about the patient’s condition and care during the incident.  
**Fields:**  
- `SITE_INJ1–SITE_INJ5`: Injury sites  
- `INJ_TYPE1–INJ_TYPE5`: Injury types  
- `CAUSE_ILL`: Cause of illness  
- `ARREST`: Arrest status  
- `ARR_DES1`: Arrest description 1  
- `ARR_DES2`: Arrest description 2  
- `AR_RHYTHM`: Arrest rhythm  
- `PULSE`: Pulse at transfer status

---

### 5. Factors
**Description:** Lists human and other contributing factors relevant to the incident.  
**Fields:**  
- `HUM_FACT1–HUM_FACT8`: Human factors  
- `OTHER_FACT`: Other factor

---

### 6. Procedures
**Description:** Details procedures performed during the EMS response.  
**Fields:**  
- `PROC_USE1–PROC_USE25`: Procedures used

---

### 7. SafetyEquipment
**Description:** Records safety equipment used during the incident.  
**Fields:**  
- `SAFE_EQP1–SAFE_EQP8`: Safety equipment

---

### 8. CareLevel
**Description:** Indicates the level of care provided during the EMS response.  
**Fields:**  
- `IL_CARE`: Intermediate Life Support Care  
- `HIGH_CARE`: High Level Care

---

## Relationships Between Node Types

### 1. Incident → Patient
**Relationship:** `HAS_PATIENT`  
**Description:** An incident may involve one or more patients.

---

### 2. Incident → EMSResponse
**Relationship:** `HAS_EMS_RESPONSE`  
**Description:** An incident has an associated EMS response.

---

### 3. Patient → ClinicalDetails
**Relationship:** `HAS_CLINICAL_DETAILS`  
**Description:** A patient has clinical details recorded for the incident.

---

### 4. Patient → Factors
**Relationship:** `HAS_FACTORS`  
**Description:** A patient may have associated human or other factors.

---

### 5. Patient → Procedures
**Relationship:** `HAS_PROCEDURES`  
**Description:** A patient may have had procedures performed.

---

### 6. Patient → SafetyEquipment
**Relationship:** `USED_SAFETY_EQUIPMENT`  
**Description:** A patient may have used or been provided with safety equipment.

---

### 7. EMSResponse → CareLevel
**Relationship:** `PROVIDED_CARE_LEVEL`  
**Description:** The EMS response included a specific level of care.

---

### 8. EMSResponse → Procedures
**Relationship:** `PERFORMED_PROCEDURES`  
**Description:** Procedures were performed as part of the EMS response.

---

### 9. EMSResponse → SafetyEquipment
**Relationship:** `INCLUDED_SAFETY_EQUIPMENT`  
**Description:** Safety equipment was used during the EMS response.

---

## Example Visualization

```aiignore
(Incident)-[:HAS_PATIENT]->(Patient)
(Incident)-[:HAS_EMS_RESPONSE]->(EMSResponse)
(Patient)-[:HAS_CLINICAL_DETAILS]->(ClinicalDetails)
(Patient)-[:HAS_FACTORS]->(Factors)
(Patient)-[:HAS_PROCEDURES]->(Procedures)
(Patient)-[:USED_SAFETY_EQUIPMENT]->(SafetyEquipment)
(EMSResponse)-[:PROVIDED_CARE_LEVEL]->(CareLevel)
(EMSResponse)-[:PERFORMED_PROCEDURES]->(Procedures)
(EMSResponse)-[:INCLUDED_SAFETY_EQUIPMENT]->(SafetyEquipment)
```

---

**Note:**  
- Some relationships may be one-to-many (e.g., one Incident to many Patients).  
- You can adjust relationship directionality or cardinality as needed for your queries and data modeling preferences.

---
