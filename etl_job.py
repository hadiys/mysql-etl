from helpers import generate_insert_query, get_area_id
from mysql.connector import Error, connect
from log import log_progress
from extract import *
from config import get_env_var
import json
import sys


# Json Keys
nearest_area = ['country', 'areaName', 'latitude', 'longitude', 'population']
current_conditions = ['FeelsLikeC', 'FeelsLikeF', 'cloudcover', 'humidity', 'localObsDateTime', 'observation_time', 'precipInches', 'precipMM', 'pressure', 'pressureInches', 'temp_C', 'temp_F', 'uvIndex', 'visibility', 'visibilityMiles', 'winddir16Point', 'winddirDegree', 'windspeedKmph', 'windspeedMiles']
daily_forecast = ['avgtempC', 'avgtempF', 'date', 'maxtempC', 'maxtempF', 'mintempC', 'mintempF', 'sunHour', 'totalSnow_cm', 'uvIndex']
hourly_forecast = ['time', 'DewPointC', 'DewPointF', 'FeelsLikeC', 'FeelsLikeF', 'HeatIndexC', 'HeatIndexF', 'WindChillC', 'WindChillF', 'WindGustKmph', 'WindGustMiles', 'chanceoffog', 'chanceoffrost', 'chanceofhightemp', 'chanceofovercast', 'chanceofrain', 'chanceofremdry', 'chanceofsnow', 'chanceofsunshine', 'chanceofthunder', 'chanceofwindy', 'cloudcover', 'diffRad', 'humidity', 'precipInches', 'precipMM', 'pressure', 'pressureInches', 'shortRad', 'tempC', 'tempF', 'uvIndex', 'visibility', 'visibilityMiles', 'winddir16Point', 'winddirDegree', 'windspeedKmph', 'windspeedMiles']

# Schema
current_conditions_columns = ['area_id', 'weather_code_id', 'feels_likeC', 'feels_likeF', 'cloudcover', 'humidity', 'localObsDateTime', 'observation_time', 'precipInches', 'precipMM', 'pressure', 'pressureInches', 'temp_C', 'temp_F', 'uvIndex', 'visibility', 'visibilityMiles', 'winddir16Pt', 'winddirDegree', 'windspeedKmph', 'windspeedMiles']
nearest_area_columns = ['country', 'area_name', 'latitude', 'longitude', 'population']
daily_forecast_columns = ['current_conditions_id', 'forecast_day', 'area_id', 'avgTempC', 'avgTempF', 'forecast_date', 'maxTempC', 'maxTempF', 'minTempC', 'minTempF', 'sunHour', 'totalSnow_cm', 'uvIndex']
hourly_forecast_columns = ['current_conditions_id', 'forecast_day', 'area_id', 'weather_code_id', 'hour', 'dewPointC', 'dewPointF', 'feelsLikeC', 'feelsLikeF', 'heatIndexC', 'heatIndexF', 'windChillC', 'windChillF', 'windGustKmph', 'windGustMiles', 'chanceoffog', 'chanceoffrost', 'chanceofhightemp', 'chanceofovercast', 'chanceofrain', 'chanceofremdry', 'chanceofsnow', 'chanceofsunshine', 'chanceofthunder', 'chanceofwindy', 'cloudcover', 'diffRad', 'humidity', 'precipInches', 'precipMM', 'pressure', 'pressureInches', 'shortRad', 'tempC', 'tempF', 'uvIndex', 'visibility', 'visibilityMiles', 'winddir16Pt', 'winddirDegree', 'windspeedKmph', 'windspeedMiles']

DB = get_env_var('DB')
HOST = get_env_var('HOST')
USER = get_env_var('USER')
PW = get_env_var('PW')

def etl():
    try:
        conn = connect(database=DB, host=HOST, username=USER, password=PW)
        cursor = conn.cursor()
        conn.autocommit = False # Disable auto-commit mode (start a transaction)
        
        multi_ins_count = 0
        table_name = ''

        with open(weather_data, 'r') as file:
            data = json.load(file)
        
        table_name = 'NEAREST_AREA'
        values = parse_area(data, nearest_area)
        insert_query = generate_insert_query(table_name, nearest_area_columns, ignore=True)
        
        area = values[1] #Save the name of the area for logging
        
        cursor.execute(insert_query, values)
        
        area_id = get_area_id(values[1], cursor)[0]
        
        log_progress('%s row(s) inserted into %s' % (cursor.rowcount, table_name))        

        table_name = 'CURRENT_CONDITIONS'
        values = parse_condition(data, current_conditions, cursor, area_id)
        insert_query = generate_insert_query(table_name, current_conditions_columns)
        
        cursor.execute(insert_query, values)
        
        current_conditions_id = cursor.lastrowid
        
        log_progress('%s row(s) inserted into %s' % (cursor.rowcount, table_name))        
        
        table_name = 'DAILY_FORECAST'
        for day in range(3):
            values = parse_daily_forecast(data, daily_forecast, day, current_conditions_id, area_id)
            insert_query = generate_insert_query(table_name, daily_forecast_columns)
            cursor.execute(insert_query, values)
            
            multi_ins_count += cursor.rowcount
        
        log_progress('%s row(s) inserted into %s' % (multi_ins_count, table_name))
        
        multi_ins_count = 0

        table_name = 'HOURLY_FORECAST'
        for day in range(3):
            for hour in range(8):
                values = parse_hourly_forecast(data, hourly_forecast, day, hour, cursor, current_conditions_id, area_id)
                insert_query = generate_insert_query(table_name, hourly_forecast_columns)
                cursor.execute(insert_query, values)
                
                multi_ins_count += cursor.rowcount

        log_progress('%s row(s) inserted into %s' % (multi_ins_count, table_name))

        conn.commit()
        log_progress(f"Successfully inserted records for {area}")

    except Error as err:
        conn.rollback()
        log_progress(f"Error: {err}")
    finally:
        cursor.close()
        conn.close()

if __name__ == "__main__":
    # Ensure the script is called with a JSON file argument
    if len(sys.argv) != 2:
        print("Usage: python <script.py> <json_file>")
        sys.exit(1)

    # Get the JSON file path from the command-line argument
    weather_data = sys.argv[1]
    etl()