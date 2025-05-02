// Race
LOAD CSV WITH HEADERS FROM 'file:///codes/race_codes.csv' AS row
MERGE (c:RaceCode {code: row.code})
SET c.label = row.label;

// Ethnicity
LOAD CSV WITH HEADERS FROM 'file:///codes/ethnicity_codes.csv' AS row
MERGE (c:EthnicityCode {code: row.code})
SET c.label = row.label;

// Gender
LOAD CSV WITH HEADERS FROM 'file:///codes/gender_codes.csv' AS row
MERGE (c:GenderCode {code: row.code})
SET c.label = row.label;

// Human Factor
LOAD CSV WITH HEADERS FROM 'file:///codes/human_factor_codes.csv' AS row
MERGE (c:HumanFactorCode {code: row.code})
SET c.label = row.label;

// Injury Site
LOAD CSV WITH HEADERS FROM 'file:///codes/injury_site_codes.csv' AS row
MERGE (c:InjurySiteCode {code: row.code})
SET c.label = row.label;

// Injury Type
LOAD CSV WITH HEADERS FROM 'file:///codes/injury_type_codes.csv' AS row
MERGE (c:InjuryTypeCode {code: row.code})
SET c.label = row.label;

// Cause of Illness
LOAD CSV WITH HEADERS FROM 'file:///codes/cause_illness_codes.csv' AS row
MERGE (c:CauseIllnessCode {code: row.code})
SET c.label = row.label;

// Safety Equipment
LOAD CSV WITH HEADERS FROM 'file:///codes/safety_equipment_codes.csv' AS row
MERGE (c:SafetyEquipmentCode {code: row.code})
SET c.label = row.label;

// Arrest Rhythm
LOAD CSV WITH HEADERS FROM 'file:///codes/arrest_rhythm_codes.csv' AS row
MERGE (c:ArrestRhythmCode {code: row.code})
SET c.label = row.label;

// Patient Status
LOAD CSV WITH HEADERS FROM 'file:///codes/patient_status_codes.csv' AS row
MERGE (c:PatientStatusCode {code: row.code})
SET c.label = row.label;

// EMS Disposition
LOAD CSV WITH HEADERS FROM 'file:///codes/ems_disposition_codes.csv' AS row
MERGE (c:EMSDispositionCode {code: row.code})
SET c.label = row.label;

// Care Level
LOAD CSV WITH HEADERS FROM 'file:///codes/care_level_codes.csv' AS row
MERGE (c:CareLevelCode {code: row.code})
SET c.label = row.label;

// Procedure Codes
LOAD CSV WITH HEADERS FROM 'file:///codes/procedure_codes.csv' AS row
MERGE (c:ProcedureCode {code: row.code})
SET c.label = row.label;
