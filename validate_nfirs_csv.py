import csv
import re
import sys
from typing import Dict, List

EXPECTED_HEADERS = [
    'INCIDENT_KEY', 'STATE', 'FDID', 'INC_DATE', 'INC_NO', 'EXP_NO', 'VERSION',
    'PATIENT_NO', 'AGE', 'GENDER', 'RACE', 'ETH_EMS', 'PAT_STATUS',
    'ARRIVAL', 'TRANSPORT', 'PROVIDER_A', 'EMS_DISPO',
    'SITE_INJ1', 'SITE_INJ2', 'SITE_INJ3', 'SITE_INJ4', 'SITE_INJ5',
    'INJ_TYPE1', 'INJ_TYPE2', 'INJ_TYPE3', 'INJ_TYPE4', 'INJ_TYPE5',
    'CAUSE_ILL', 'ARREST', 'ARR_DES1', 'ARR_DES2', 'AR_RHYTHM', 'PULSE',
    'PROC_USE1', 'PROC_USE2', 'PROC_USE3', 'PROC_USE4', 'PROC_USE5', 'PROC_USE6',
    'PROC_USE7', 'PROC_USE8', 'PROC_USE9', 'PROC_USE10', 'PROC_USE11', 'PROC_USE12',
    'PROC_USE13', 'PROC_USE14', 'PROC_USE15', 'PROC_USE16', 'PROC_USE17', 'PROC_USE18',
    'PROC_USE19', 'PROC_USE20', 'PROC_USE21', 'PROC_USE22', 'PROC_USE23', 'PROC_USE24',
    'PROC_USE25', 'SAFE_EQP1', 'SAFE_EQP2', 'SAFE_EQP3', 'SAFE_EQP4', 'SAFE_EQP5',
    'SAFE_EQP6', 'SAFE_EQP7', 'SAFE_EQP8', 'IL_CARE', 'HIGH_CARE',
    'HUM_FACT1', 'HUM_FACT2', 'HUM_FACT3', 'HUM_FACT4', 'HUM_FACT5',
    'HUM_FACT6', 'HUM_FACT7', 'HUM_FACT8', 'OTHER_FACT'
]

DATE_PATTERN = re.compile(r'^\d{8}$')  # MMDDYYYY
DATETIME_PATTERN = re.compile(r'^\d{12}$')  # MMDDYYYYHHmm
NUMERIC_PATTERN = re.compile(r'^\d*\.?\d*$')  # Allows decimals
CODE_PATTERN = re.compile(r'^[A-Z0-9]{2}$')  # Allows letters and numbers
FACTOR_PATTERN = re.compile(r'^\d{1,2}$')  # 1-2 digit numbers
VALID_PULSE_VALUES = ['1', '2', '']
VALID_ARREST_VALUES = ['1', '2', '']
VALID_FACTOR_VALUES = ['', 'N']  # Empty or 'N' for None


def collect_errors(row: Dict[str, str], row_number: int) -> List[str]:
    """Collect validation errors for a single CSV row."""
    errors: List[str] = []

    # Required field checks
    if not row['INCIDENT_KEY']:
        errors.append(f"Row {row_number}: Missing INCIDENT_KEY")

    # Date/time validation
    inc_date = row['INC_DATE']
    if not DATE_PATTERN.match(inc_date):
        errors.append(f"Row {row_number}: Invalid INC_DATE format '{inc_date}' (MMDDYYYY required)")

    for field in ['ARRIVAL', 'TRANSPORT']:
        value = row[field]
        if value and not DATETIME_PATTERN.match(value):
            errors.append(f"Row {row_number}: Invalid {field} format '{value}' (MMDDYYYYHHmm required)")

    # Numeric field validation
    age = row['AGE']
    if age and not NUMERIC_PATTERN.match(age):
        errors.append(f"Row {row_number}: Invalid AGE value '{age}' (numeric/decimal required)")

    # Coded field validation
    arrest = row['ARREST']
    if arrest not in VALID_ARREST_VALUES:
        errors.append(f"Row {row_number}: ARREST must be 1, 2, or empty (found '{arrest}')")

    pulse = row['PULSE']
    if pulse not in VALID_PULSE_VALUES:
        errors.append(f"Row {row_number}: Invalid PULSE value '{pulse}'")

    # Procedure validation
    for j in range(1, 26):
        if proc := row[f'PROC_USE{j}']:
            if proc == "NN":  # Special case
                continue
            if not CODE_PATTERN.match(proc):
                errors.append(f"Row {row_number}: PROC_USE{j} invalid code '{proc}'")

    # Factor validation
    for j in range(1, 9):
        factor = row.get(f'HUM_FACT{j}', '')
        if factor not in VALID_FACTOR_VALUES and not FACTOR_PATTERN.match(factor):
            errors.append(f"Row {row_number}: HUM_FACT{j} invalid code '{factor}'")

    other_factor = row.get('OTHER_FACT', '')
    if other_factor not in VALID_FACTOR_VALUES and not FACTOR_PATTERN.match(other_factor):
        errors.append(f"Row {row_number}: OTHER_FACT invalid code '{other_factor}'")

    return errors


def validate_csv(file_path: str) -> int:
    """Validate NFIRS EMS CSV file and return exit code."""
    errors: List[str] = []

    with open(file_path, 'r', newline='', encoding='utf-8') as csvfile:
        reader = csv.DictReader(csvfile)
        headers = reader.fieldnames

        # Header validation
        missing = set(EXPECTED_HEADERS) - set(headers)
        extra = set(headers) - set(EXPECTED_HEADERS)
        if missing:
            errors.append(f"Missing headers: {', '.join(missing)}")
        if extra:
            errors.append(f"Extra headers: {', '.join(extra)}")

        # Row validation
        for row_number, row in enumerate(reader, start=2):  # Row numbers start at 2
            errors += collect_errors(row, row_number)

    if errors:
        print("\n".join(errors))
        return 1
    print("CSV validation successful!")
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python validate_nfirs_csv.py <csv_file>")
        sys.exit(1)
    sys.exit(validate_csv(sys.argv[1]))
