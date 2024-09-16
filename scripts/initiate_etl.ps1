# Define cities
$cities = @('Cairo', 'Mecca', 'Abu_Dhabi', 'Bayrut', 'Marrakesh', 'Jeddah')

# Define paths and variables
$baseUrl = "https://wttr.in"
$dataDir = "C:\path\to\your\project\etl\data"
$etlScript = "C:\path\to\your\project\etl\etl_job.py"
$logScript = "C:\path\to\your\project\etl\log.py"
$serverStart = "C:\path\to\mysql\bin\mysqld --console"
$serverStop = "C:\path\to\mysql\bin\mysqladmin shutdown"
$pyenv = "C:\path\to\python_venv\Scripts\Activate.ps1"
$py3 = "C:\path\to\python\python.exe"
$wget = "C:\path\to\wget\wget.exe"
$timestampSeconds = [int](Get-Date -UFormat %s)

# Create data directory if it doesn't exist
if (-not (Test-Path $dataDir)) {
    New-Item -ItemType Directory -Path $dataDir
}

# Check if MySQL is running, start it if not
if (-not (Get-Process mysqld -ErrorAction SilentlyContinue)) {
    & $serverStart
} else {
    Write-Host "MySQL server already running"
}

# Activate Python virtual environment
& $pyenv

# Log starting message
& $py3 $logScript "Starting Extraction Process" "Shell"

# Loop through cities and download weather data
foreach ($city in $cities) {
    $url = "$baseUrl/$city?format=j1"
    $outputFile = "$dataDir\$city`_$timestampSeconds.json"

    & $wget -q -O $outputFile $url

    if ((Get-Item $outputFile).length -gt 0) {
        & $py3 $logScript "Successfully downloaded data from $url to $outputFile" "Shell"
        
        & $py3 $etlScript $outputFile

        if ($LASTEXITCODE -eq 0) {
            & $py3 $logScript "Successfully processed $outputFile" "Shell"
        } else {
            & $py3 $logScript "Script failed for $outputFile" "Shell"
        }
    } else {
        & $py3 $logScript "Failed to download data from $url" "Shell"
    }
}

# Deactivate virtual environment
deactivate

# Stop MySQL server
& $serverStop
