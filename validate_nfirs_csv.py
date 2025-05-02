import sys

from web_backend.app.utils.validation import validate_csv_file

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python validate_nfirs_csv.py <csv_file>")
        sys.exit(1)
    if errors := validate_csv_file(sys.argv[1]):
        print("\n".join(errors))
        sys.exit(1)
    print("CSV validation successful.")
    sys.exit(0)
