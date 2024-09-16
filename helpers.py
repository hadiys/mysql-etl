import mysql.connector
from log import log_progress

def get_weather_code_id(weather_code, cursor):
    try:
        cursor.execute('SELECT weather_code_id FROM weather_code where weather_code_id = %s;' % (weather_code))
        result = cursor.fetchone()

        return result
    
    except mysql.connector.Error as e:
        log_progress(f"Error: {e}")

def get_area_id(area_name, cursor):
    try:
        cursor.execute('SELECT area_id FROM nearest_area where area_name = "%s";' % (area_name))
        result = cursor.fetchone()

        return result
    
    except mysql.connector.Error as e:
        log_progress(f"Error: {e}")
        
def generate_insert_query(table, columns, ignore=False):
    columns_str = ', '.join(columns)
    placeholders = ', '.join(['%s'] * len(columns))
    query = f"INSERT {'IGNORE' if ignore==True else ''} INTO {table} ({columns_str}) VALUES({placeholders});\n"

    return query

def cast_value(value):
    try:
        return int(value)
    except ValueError:
        pass

    try:
        return float(value)
    except ValueError:
        pass

    return value

    