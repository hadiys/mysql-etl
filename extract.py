import helpers
import traceback
import sys
from log import log_progress

def parse_area(data, keys):
    try:
        entity = data['nearest_area'][0]
        values = []

        for i in range(len(keys)):
            value = entity[keys[i]]
            
            if(isinstance(value, list)):
                value = entity[keys[i]][0]['value']
            
            casted_value = helpers.cast_value(value)
            values.append(casted_value)

        log_progress('Success')
        
        return values
    
    except Exception as e:
        log_progress(traceback.format_exception(*sys.exc_info()))

def parse_condition(data, keys, cursor, fk_area):   
    try:
        entity = data['current_condition'][0]
        weather_code = entity['weatherCode']
        weather_code_id = helpers.get_weather_code_id(weather_code, cursor)[0]
        
        values = [fk_area, weather_code_id]

        for i in range(len(keys)):
            value = entity[keys[i]]
            casted_value = helpers.cast_value(value)
            values.append(casted_value)
        
        log_progress('Success')

        return values
    
    except Exception as e:
        log_progress(traceback.format_exception(*sys.exc_info()))

def parse_daily_forecast(data, keys, day, fk_conditions, fk_area):
    try:
        entity = data['weather']
        values = [fk_conditions, day+1, fk_area]

        for i in range(len(keys)):
            value = entity[day][keys[i]]
            casted_value = helpers.cast_value(value)
            values.append(casted_value)
        
        if(day == 2): #Since this func is called 3 times per transaction, log 'Success' once (when all values are extracted) 
            log_progress('Success')

        return values
    
    except Exception as e:
        log_progress(traceback.format_exception(*sys.exc_info()))

def parse_hourly_forecast(data, keys, day, hour, cursor, fk_conditions, fk_area):
    try: 
        entity = data['weather'][day]['hourly']
        weather_code = entity[hour]['weatherCode']
        weather_code_id = helpers.get_weather_code_id(weather_code, cursor)[0]
        
        values = [fk_conditions, day+1, fk_area, weather_code_id]    

        for i in range(len(keys)):
            value = entity[hour][keys[i]]
            casted_value = helpers.cast_value(value)
            values.append(casted_value)

        if(day == 2 and hour == 7): #Since this func is called 8 times per transaction, log 'Success' once (when all values are extracted) 
            log_progress('Success')
        
        return values
    
    except Exception as e:
        log_progress(traceback.format_exception(*sys.exc_info()))