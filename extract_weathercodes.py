import sys
import json
import mysql.connector
from config import get_env_var
from log import log_progress

DB = get_env_var('DB')
HOST = get_env_var('HOST')
USER = get_env_var('USER')
PW = get_env_var('PW')

def extract_codes(codes_file):
    conn = mysql.connector.connect(database=DB, host=HOST, username=USER, password=PW)
    cursor = conn.cursor()
    multi_ins_count = 0

    with open(codes_file, 'r') as file:
        data = json.load(file)

    try:
        for key, value in data.items():
            cursor.execute('INSERT INTO WEATHER_CODE(weather_code_id, weatherDesc) VALUES (%s, %s);', (key, value))
            conn.commit()
            multi_ins_count += cursor.rowcount

        log_progress('%s row(s) inserted into %s' % (multi_ins_count, 'WEATHER_CODE'))

    except Exception as e:
        conn.rollback()
        log_progress('Insert failed: %s' % e)
    finally:
        cursor.close()
        conn.close()


if __name__ == "__main__":
    # Ensure the script is called with a JSON file argument
    if len(sys.argv) != 2:
        print("Usage: python <script.py> <json_file>")
        sys.exit(1)

    # Get the JSON file path from the command-line argument
    weather_codes = sys.argv[1]
    extract_codes(weather_codes)