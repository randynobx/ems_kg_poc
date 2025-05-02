// nfirs_ems_main_data_load.cypher
LOAD CSV WITH HEADERS FROM 'file:///nfirs_all_incident_pdr_2023__ems.csv' AS row

// 1. Create Incident Node
MERGE (i:Incident {incident_key: row.INCIDENT_KEY})
SET
  i.state = row.STATE,
  i.fdid = row.FDID,
  i.inc_date = date(SUBSTRING(row.INC_DATE, 4, 4) + '-' + SUBSTRING(row.INC_DATE, 0, 2) + '-' + SUBSTRING(row.INC_DATE, 2, 2)),
  i.inc_no = row.INC_NO,
  i.exp_no = row.EXP_NO,
  i.version = row.VERSION

// 2. Create Patient Node and Demographics
WITH row, i WHERE row.PATIENT_NO IS NOT NULL
MERGE (p:Patient {id: row.INCIDENT_KEY + '-' + row.PATIENT_NO})
SET p.age = CASE WHEN row.AGE <> '' THEN toInteger(row.AGE) ELSE null END
MERGE (i)-[:HAS_PATIENT]->(p)

// Race relationship
WITH row, p WHERE row.RACE <> ''
MERGE (rc:RaceCode {code: row.RACE})
MERGE (p)-[:HAS_RACE]->(rc)

// Ethnicity relationship
WITH row, p WHERE row.ETH_EMS <> ''
MERGE (ec:EthnicityCode {code: row.ETH_EMS})
MERGE (p)-[:HAS_ETHNICITY]->(ec)

// Gender relationship
WITH row, p WHERE row.GENDER <> ''
MERGE (gc:GenderCode {code: row.GENDER})
MERGE (p)-[:HAS_GENDER]->(gc)

// 3. Clinical Details with Injury Relationships
WITH row, p WHERE COALESCE(row.SITE_INJ1, row.ARREST) IS NOT NULL
MERGE (cd:ClinicalDetails {id: p.id + '-clinical'})
SET
  cd.arrest = row.ARREST,
  cd.arr_des1 = row.ARR_DES1,
  cd.arr_des2 = row.ARR_DES2,
  cd.pulse = row.PULSE
MERGE (p)-[:HAS_CLINICAL_DETAILS]->(cd)

// Process injury pairs (site + type)
UNWIND range(1,5) AS idx
WITH row, cd, idx
WHERE row["SITE_INJ" + idx] <> '' AND row["INJ_TYPE" + idx] <> ''
MERGE (site:InjurySiteCode {code: row["SITE_INJ" + idx]})
MERGE (type:InjuryTypeCode {code: row["INJ_TYPE" + idx]})
CREATE (cd)-[:HAS_INJURY]->(inj:Injury)
MERGE (inj)-[:HAS_SITE]->(site)
MERGE (inj)-[:HAS_TYPE]->(type)

// 4. Human Factors
UNWIND [row.HUM_FACT1, row.HUM_FACT2, row.HUM_FACT3, row.HUM_FACT4, row.HUM_FACT5,
        row.HUM_FACT6, row.HUM_FACT7, row.HUM_FACT8] AS factor
WITH row, p, factor WHERE factor <> ''
MERGE (hfc:HumanFactorCode {code: factor})
MERGE (p)-[:HAS_HUMAN_FACTOR]->(hfc)

// 5. Procedures
UNWIND [row.PROC_USE1, row.PROC_USE2, row.PROC_USE3, row.PROC_USE4, row.PROC_USE5,
        row.PROC_USE6, row.PROC_USE7, row.PROC_USE8, row.PROC_USE9, row.PROC_USE10,
        row.PROC_USE11, row.PROC_USE12, row.PROC_USE13, row.PROC_USE14, row.PROC_USE15,
        row.PROC_USE16, row.PROC_USE17, row.PROC_USE18, row.PROC_USE19, row.PROC_USE20,
        row.PROC_USE21, row.PROC_USE22, row.PROC_USE23, row.PROC_USE24, row.PROC_USE25] AS proc
WITH row, p, proc WHERE proc <> ''
MERGE (pc:ProcedureCode {code: proc})
MERGE (p)-[:HAS_PROCEDURE]->(pc)

// 6. EMS Response
WITH row, i WHERE row.PROVIDER_A <> ''
MERGE (er:EMSResponse {id: i.incident_key + '-response'})
SET
  er.arrival = CASE WHEN row.ARRIVAL <> '' THEN datetime({
    year: toInteger(SUBSTRING(row.ARRIVAL, 4, 4)),
    month: toInteger(SUBSTRING(row.ARRIVAL, 0, 2)),
    day: toInteger(SUBSTRING(row.ARRIVAL, 2, 2)),
    hour: toInteger(SUBSTRING(row.ARRIVAL, 8, 2)),
    minute: toInteger(SUBSTRING(row.ARRIVAL, 10, 2))
  }) ELSE null END,
  er.transport = CASE WHEN row.TRANSPORT <> '' THEN datetime({
    year: toInteger(SUBSTRING(row.TRANSPORT, 4, 4)),
    month: toInteger(SUBSTRING(row.TRANSPORT, 0, 2)),
    day: toInteger(SUBSTRING(row.TRANSPORT, 2, 2)),
    hour: toInteger(SUBSTRING(row.TRANSPORT, 8, 2)),
    minute: toInteger(SUBSTRING(row.TRANSPORT, 10, 2))
  }) ELSE null END
MERGE (i)-[:HAS_EMS_RESPONSE]->(er)

// EMS Disposition
WITH row, er WHERE row.EMS_DISPO <> ''
MERGE (edc:EMSDispositionCode {code: row.EMS_DISPO})
MERGE (er)-[:HAS_DISPOSITION]->(edc)

// Care Level (IL_CARE takes precedence)
WITH row, er WHERE COALESCE(row.IL_CARE, row.HIGH_CARE) IS NOT NULL
MERGE (clc:CareLevelCode {code: COALESCE(row.IL_CARE, row.HIGH_CARE)})
MERGE (er)-[:PROVIDED_CARE_LEVEL]->(clc)

// Create Constraints
CREATE CONSTRAINT incident_unique IF NOT EXISTS FOR (i:Incident) REQUIRE i.incident_key IS UNIQUE;
CREATE CONSTRAINT patient_unique IF NOT EXISTS FOR (p:Patient) REQUIRE p.id IS UNIQUE;
