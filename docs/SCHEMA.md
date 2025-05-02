# NFIRS 5.0 EMS Module Knowledge Graph Schema Documentation (Revised)

## Node Types

### 1. Incident
**Description:** Represents a unique EMS incident.  
**Properties:**  
- `incident_key`: Unique incident identifier  
- `state`: State code  
- `fdid`: Fire Department ID  
- `inc_date`: Date of incident (`DATE` type)  
- `inc_no`: Incident number  
- `exp_no`: Exposure number  
- `version`: NFIRS version  

---

### 2. Patient
**Description:** An individual receiving EMS care.  
**Properties:**  
- `id`: Composite ID (`INCIDENT_KEY-PATIENT_NO`)  
- `age`: Patient age  
- `pat_status`: Raw patient status code  

**Relationships:**  
- `HAS_RACE` → `RaceCode`  
- `HAS_ETHNICITY` → `EthnicityCode`  
- `HAS_GENDER` → `GenderCode`  
- `HAS_HUMAN_FACTOR` → `HumanFactorCode`  
- `HAS_PROCEDURE` → `ProcedureCode`  

---

### 3. ClinicalDetails
**Description:** Clinical observations and interventions.  
**Properties:**  
- `arrest`: Arrest status (raw value)  
- `pulse`: Pulse status (raw value)  
- `arr_des1/arr_des2`: Arrest descriptions  

**Relationships:**  
- `HAS_INJURY` → `Injury`  

---

### 4. Injury
**Description:** Specific injury instance.  
**Relationships:**  
- `HAS_SITE` → `InjurySiteCode`  
- `HAS_TYPE` → `InjuryTypeCode`  

---

### 5. EMSResponse
**Description:** EMS team actions and timeline.  
**Properties:**  
- `arrival`: Arrival time (`DATETIME`)  
- `transport`: Transport time (`DATETIME`)  

**Relationships:**  
- `HAS_DISPOSITION` → `EMSDispositionCode`  
- `PROVIDED_CARE_LEVEL` → `CareLevelCode`  

---

### 6. Code Lookup Nodes
| Node Label            | Properties           | Example Codes                     |
|-----------------------|----------------------|-----------------------------------|
| `RaceCode`            | `code`, `label`      | 1=White, 2=Black                 |
| `EthnicityCode`       | `code`, `label`      | 1=Hispanic, 2=Non-Hispanic       |
| `GenderCode`          | `code`, `label`      | 1=Male, 2=Female                 |
| `HumanFactorCode`     | `code`, `label`      | 1=Alcohol Use, 2=Drug Use        |
| `InjurySiteCode`      | `code`, `label`      | 1=Head, 2=Neck                   |
| `InjuryTypeCode`      | `code`, `label`      | 1=Burn, 2=Laceration             |
| `ProcedureCode`       | `code`, `label`      | 05=CPR, 09=IV Therapy            |
| `EMSDispositionCode`  | `code`, `label`      | 1=Transported, 2=Refused Care    |
| `CareLevelCode`       | `code`, `label`      | 1=BLS, 2=ILS, 3=ALS              |

---

## Relationships

### Primary Relationships
1. **Incident**  
   - `HAS_PATIENT` → Patient  
   - `HAS_EMS_RESPONSE` → EMSResponse  

2. **Patient**  
   - `HAS_CLINICAL_DETAILS` → ClinicalDetails  
   - `HAS_RACE` → RaceCode  
   - `HAS_PROCEDURE` → ProcedureCode  

3. **ClinicalDetails**  
   - `HAS_INJURY` → Injury  

4. **Injury**  
   - `HAS_SITE` → InjurySiteCode  
   - `HAS_TYPE` → InjuryTypeCode  

5. **EMSResponse**  
   - `PROVIDED_CARE_LEVEL` → CareLevelCode  
   - `HAS_DISPOSITION` → EMSDispositionCode  

---

## Example Visualization

