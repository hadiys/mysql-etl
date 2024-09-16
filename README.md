 # mysql-etl
ETL Pipeline in Python that ingests weather data for loading into a MySQL database

## Table of Contents ##
1. [Project Overview](#po)
2. [Features](#f)
3. [Technologies Used](#tu)
4. [Installation](#i)
5. [Configuration](#conf)
6. [Usage](#u)
7. [ETL Process Description](#etl)
8. [Database Schema](#d)
9. [Error Handling](#e)
11. [License](#l)



<h3 id="po">Project Overview</h3>

This project features an ETL pipeline that can be automated to ingest data about the weather for any given location(s), using the [wttr.in API ](https://wttr.in) and loads it into a MySQL database. The pipeline processes JSON data and loads it with respect to the relational model of the database.

The data includes detailed information about the weather, such as temperatures, chance of sunshine/rain/overcast, pressures, latitude and longitude of the location, and more. For each city, we can find the current conditions, a 3-day forecast, and 3-hourly forecasted conditions for each day's forecast. 

As the data pipeline can be automated, the dataset can grow quickly, which can be used for regular upstream loading into OLAP systems for analysis. This also creates a database system with large tables, closely mimicking real-world use cases to experiment with SQL workloads, query optimisation, engine configuration and more. 

<h3 id="f">Features</h3>

1. Versatile extraction and load (configurable list of columns and values)
2. Transactional (all or none)
3. Error & progress logging
4. Datatype checking
5. Fully automated

<h3 id="tu">Technologies Used</h3>

1. Database: MySQL
2. Programming Language: Python
3. Packages: mysql-connector, json
5. Automation: Shell scripting, Cron

<h3 id="i">Installation</h3>

1. Clone the repository and go to its root directory 

```
git clone https://github.com/hadiys/mysql-etl.git

cd mysql-etl
```


2. Setup the virtual environment (optional but recommended)

```
python3 -m venv <your_venv_name>

source <your_venv_name>/bin/activate
```

>On Windows use: `venv\Scripts\activate` instead of `source venv/bin/activate`


3. Install required packages

`pip install -r requirements.txt`


4. Install mysql server

>Note: If using MySQL Workbench, make sure to install MySQL server 8.0, as other MySQL Server version may be incompatible. Versions after 8.0, such as 8.4, may connect but some features may not be supported.

**On Mac:**

- `brew install mysql@8.0`

-  To use MySQL commands without specifying the full path, you need to link it:

    `brew link mysql@8.0 --force `

- Run secure installation and set a password for the DB root user:

    `mysql_secure_installation`

    - Choose 'Y' for 'Set root password?' and enter your password
    - Save it for later to connect to the database 
    - Choose 'Y' for all the questions afterwards


**On Windows:**

- Go to https://dev.mysql.com/downloads/installer/ to download the MYSQL installer

- Follow setup instructions https://youtu.be/u96rVINbAUI. 
    - Choose V8.0.xx as the version
    - OS: Windows
    - In the installation type, you can choose Server Setup or Custom Setup to install the server + any add ons (i.e: MySQL Workbench)

- Save the root user password to connect to the database


5. Recreate the weather database using the sql file

    - Log into mysql client with your password:
    
        `mysql -u root -p `

    - Recreate the database:
    
        `> source weatherdb_backup.sql;`

    - Check that the database was successfully created:

        `> use weather;`
        
        `> show tables;`

    - Exit the client:
    
        `> quit`

<h3 id="conf">Configuration</h3>

* Create the .env file:

`touch .env`

* Add credentials & log file path to a .env file

```
DB=WEATHER
HOST=localhost
USER=root
PW=<your_password>
LOG_FILE=/your/project/path/log/log.txt
```


<h3 id="u">Usage</h3>

1. Start the MySQL server

`mysql.server start`

2. Activate the virtual environment

`source path/to/venv/activate`

3. Populate the weather codes table (do once only):

`python3 extract_weathercodes.py resources/wttr-codes.json`

4. Download the weather data from the weather API:

`wget -q -O ./data/your_filename.json https://wttr/in/replace_with_city_name?=format=j1`

5. Run the etl script using the following command:

`python3 etl_job.py ./data/your_filename.json`

5. Log into your MySQL Workbench or mysql command line client then run the following statements to check that the data has been successfully loaded:
```
USE WEATHER;
SELECT * FROM NEAREST_AREA;
SELECT * FROM CURRENT_CONDITIONS;
SELECT * FROM DAILY_FORECAST;
SELECT * FROM HOURLY_FORECAST;
```
    
6. Stop the server when done

`mysql.server stop`

<h3 id="etl">ETL Process Description</h3>

**Overview**

The ETL proceeds with respect to the relational model or schema of the data. Since the tables have parent-child relationships, parent tables are populated first, then intermediate tables (ones that are child and also parent) and child tables finally.

**A note on automation**

The automation of the ETL process can be done by setting up a shell script to run all the steps mentioned in the Usage section.

_Link to shell script in scripts folder_

The process begins when the `etl_job.py` script is called with an argument that specifies the json file containing our data, extracting/parsing data from json, generating SQL `INSERT` statement, and executing the statement against the database. 

The process is repeated for each entity in the database. If an error occurs during any phase of the ETL, the MySQL transaction is aborted to ensure data consistency in the database and the error is appended to the log file. 

A transaction consists of 1 row describing the current conditions, 3 rows describing 3-day forecast ahead of the current day, and 8 rows describing the forecast every 3 hours for each day. Therefore the transaction creates 28 rows across 3 tables. 

<h3 id="d">Database Schema</h3>

| Table Type | Table names | 
|---------------|----------------|
| Parent | NEAREST_AREA, WEATHER_CODE | 
| Intermediate |CURRENT_CONDITIONS, DAILY_FORECAST| 
| Child |HOURLY_FORECAST | 

>To explore the full schema, run the commands `show tables` or `describe <table_name>` in MySQL Workbench or command-line client.

![FINAL ERD](path/to/img)


<h3 id="e">Error Handling</h3>

Error is handled in 3 error-prone areas:
1. The Python generic `Exception` type. This error is caught during execution for any of the parse functions in `extract.py`, which are responsible for extracting values from the json data.

2. The mysql-connector generic `Error` type. Used in a try-except block to wrap the ETL process as a transaction, and catches any MySQL error that might occur during database interactions. This error can also be caught during the execution of helper functions like `get_area_id()` and `get_weather_code_id()` which also retrieve ids from the database.

3. `ValueError` is implemented as a type-checking mechanism in the helper function `cast_value()`. Since all the json values are strings, the try-except block with a `ValueError` ensures values are returned as their underlying type so that they are correctly inserted into the database (i.e: if the string '23' is inserted into a column with a type `INT` its value will be 0 so it must be casted to `INT`)


>All of the above errors are logged to the log file specified in the `.env` variable **LOG_FILE**, with the following format:_<p>timestamp | executing function | message</p>_

<h3 id="l">License</h3>
MIT License

Copyright (c) 2024 Hadi Saleh
