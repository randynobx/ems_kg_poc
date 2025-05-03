:auto

LOAD CSV WITH HEADERS FROM $csvPath AS row
CALL {
WITH row
// 1. Incident Node
MERGE (i:Incident {incident_key: row.INCIDENT_KEY})
SET i.version = row.VERSION,
i.state = row.STATE,
i.fdid = row.FDID,
i.inc_date = date(substring(row.INC_DATE, 4, 4) + '-' +
substring(row.INC_DATE, 0, 2) + '-' +
substring(row.INC_DATE, 2, 2)),
i.inc_no = row.INC_NO,
i.exp_no = row.EXP_NO

// 2. Patient Node
WITH i, row
  WHERE row.PATIENT_NO IS NOT NULL
MERGE (p:Patient {id: i.incident_key + '-' + row.PATIENT_NO})
SET p.age = CASE WHEN row.AGE <> '' THEN toInteger(row.AGE)
  ELSE null
  END,
p.pat_status = row.PAT_STATUS
MERGE (i)-[:HAS_PATIENT]->(p)

// 3. Race Relationship
WITH p, i, row
  WHERE row.RACE <> ''
MERGE (rc:RaceCode {code: row.RACE, version: i.version})
MERGE (p)-[:HAS_RACE]->(rc)

// 4. Ethnicity Relationship
WITH p, i, row
  WHERE row.ETH_EMS <> ''
MERGE (ec:EthnicityCode {code: row.ETH_EMS, version: i.version})
MERGE (p)-[:HAS_ETHNICITY]->(ec)

// 5. Gender Relationship
WITH p, i, row
  WHERE row.GENDER <> ''
MERGE (gc:GenderCode {code: row.GENDER, version: i.version})
MERGE (p)-[:HAS_GENDER]->(gc)

// 6. Clinical Details
WITH p, i, row
  WHERE coalesce(row.SITE_INJ1, row.ARREST) IS NOT NULL
MERGE (cd:ClinicalDetails {id: p.id + '-clinical'})
SET cd.arrest = row.ARREST,
cd.pulse = row.PULSE,
cd.arr_des1 = row.ARR_DES1,
cd.arr_des2 = row.ARR_DES2,
cd.ar_rhythm = row.AR_RHYTHM
MERGE (p)-[:HAS_CLINICAL_DETAILS]->(cd)

// 7. Injuries (Site + Type pairs)
WITH cd, i, row, p
UNWIND range(1, 5) AS idx
WITH cd, i, row, idx, p
  WHERE row['SITE_INJ' + idx] <> '' AND row['INJ_TYPE' + idx] <> ''
MERGE (site:InjurySiteCode {code: row['SITE_INJ' + idx], version: i.version})
MERGE (type:InjuryTypeCode {code: row['INJ_TYPE' + idx], version: i.version})
CREATE (cd)-[:HAS_INJURY]->(inj:Injury)
MERGE (inj)-[:HAS_SITE]->(site)
MERGE (inj)-[:HAS_TYPE]->(type)

// 8. Human Factors
WITH p, i, row
UNWIND [row.HUM_FACT1, row.HUM_FACT2, row.HUM_FACT3, row.HUM_FACT4,
  row.HUM_FACT5, row.HUM_FACT6, row.HUM_FACT7, row.HUM_FACT8] AS factor
WITH p, i, factor, row
  WHERE factor <> ''
MERGE (hfc:HumanFactorCode {code: factor, version: i.version})
MERGE (p)-[:HAS_HUMAN_FACTOR]->(hfc)

// 9. Procedures
WITH p, i, row
UNWIND [row.PROC_USE1, row.PROC_USE2, row.PROC_USE3, row.PROC_USE4, row.PROC_USE5,
  row.PROC_USE6, row.PROC_USE7, row.PROC_USE8, row.PROC_USE9, row.PROC_USE10,
  row.PROC_USE11, row.PROC_USE12, row.PROC_USE13, row.PROC_USE14, row.PROC_USE15,
  row.PROC_USE16, row.PROC_USE17, row.PROC_USE18, row.PROC_USE19, row.PROC_USE20,
  row.PROC_USE21, row.PROC_USE22, row.PROC_USE23, row.PROC_USE24, row.PROC_USE25] AS proc
WITH p, i, proc, row
  WHERE proc <> ''
MERGE (pc:ProcedureCode {code: proc, version: i.version})
MERGE (p)-[:HAS_PROCEDURE]->(pc)

// 10. EMS Response
WITH p, i, row
  WHERE row.PROVIDER_A <> ''
MERGE (er:EMSResponse {id: p.id + '-response'})
SET er.arrival = datetime({
  year:   toInteger(substring(row.ARRIVAL, 4, 4)),
  month:  toInteger(substring(row.ARRIVAL, 0, 2)),
  day:    toInteger(substring(row.ARRIVAL, 2, 2)),
  hour:   toInteger(substring(row.ARRIVAL, 8, 2)),
  minute: toInteger(substring(row.ARRIVAL, 10, 2))
}),
er.ems_dispo = row.EMS_DISPO
MERGE (p)-[:HAS_EMS_RESPONSE]->(er)

// 11. EMS Disposition
WITH er, i, row
  WHERE row.EMS_DISPO <> ''
MERGE (edc:EMSDispositionCode {code: row.EMS_DISPO, version: i.version})
MERGE (er)-[:HAS_DISPOSITION]->(edc)

// 12. Care Level
WITH er, i, row
  WHERE coalesce(row.IL_CARE, row.HIGH_CARE) IS NOT NULL
MERGE (clc:CareLevelCode {code: coalesce(row.IL_CARE, row.HIGH_CARE), version: i.version})
MERGE (er)-[:PROVIDED_CARE_LEVEL]->(clc)
} IN TRANSACTIONS OF 5000 ROWS
