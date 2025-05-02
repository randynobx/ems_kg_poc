import logging
import os
import sys

from web_backend.app.utils.import_data import NFIRSImporter

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    if len(sys.argv) != 2:
        print("Usage: python nfirs_ems_importer.py <main_csv_path>")
        sys.exit(1)
    main_csv_path = sys.argv[1]
    if not os.path.isfile(main_csv_path):
        print(f"File not found: {main_csv_path}")
        sys.exit(1)
    importer = NFIRSImporter('config.ini')
    try:
        importer.import_lookup_codes()
        importer.import_ems_data(main_csv_path)
    finally:
        importer.close()
