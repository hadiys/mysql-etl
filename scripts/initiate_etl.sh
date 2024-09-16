#!/bin/bash

declare -a CITIES=('Cairo' 'Mecca' 'Abu_Dhabi' 'Bayrut' 'Marrakesh' 'Jeddah')

BASE_URL="https://wttr.in" 
DATA_DIR="/path/to/your/project/etl/data"
ETL_SCRIPT="/path/to/your/project/etl/etl_job.py"
LOG_SCRIPT="/path/to/your/project/etl/log.py"
SERVER_START="/path/to/mysql/bin/mysql.server start"
SERVER_STOP="/path/to/mysql/bin/mysql.server stop"
PYENV="/path/to/python_venv/bin/activate"
PY3="/path/to/python/bin/python3"
WGET="/path/to/wget/wget"
TIMESTAMP_SECONDS=$(date +%s)

mkdir -p $DATA_DIR

if pgrep mysqld > /dev/null 2>&1; then 
    echo "MySQL server already running"
else
    $SERVER_START
fi

source $PYENV

$PY3 $LOG_SCRIPT "Starting Extraction Process" "Shell"

for endpoint in "${CITIES[@]}"
do
    URL="$BASE_URL/${endpoint}?format=j1"
    
    OUTPUT_FILE="${DATA_DIR}/${endpoint}_${TIMESTAMP_SECONDS}"

    $WGET -q -O "$OUTPUT_FILE" "$URL"
    
    if [[ -s "$OUTPUT_FILE" ]]; then

        $PY3 $LOG_SCRIPT "Successfully downloaded data from ${URL} to ${OUTPUT_FILE}" "Shell"
        
        $PY3 $ETL_SCRIPT "$OUTPUT_FILE"

        if [[ $? -eq 0 ]]; then
            $PY3 $LOG_SCRIPT "Successfully processed ${OUTPUT_FILE}" "Shell"
            
        else
            $PY3 $LOG_SCRIPT "Script failed for ${OUTPUT_FILE}" "Shell"
        fi 

    else
        $PY3 $LOG_SCRIPT "Failed to download data from ${URL}" "Shell"
    fi

done

deactivate

$SERVER_STOP
