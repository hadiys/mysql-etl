import sys 
import inspect
from datetime import datetime
from config import get_env_var

def log_progress(message, fn=None):
    log_file = get_env_var('LOG_FILE')
    now = datetime.now()
    timestamp = now.strftime('%Y-%h-%d-%H:%M:%S')

    calling_fn = fn if fn else inspect.stack()[1].function + '()'

    with open(log_file, "a") as f:
        f.write(timestamp + ' ' + calling_fn + ': ' + message + '\n')

if __name__ == "__main__":
    # The script can be called with 3 arguments: script.py file.json custom_caller_name
    if len(sys.argv) > 2:
        log_progress(sys.argv[1], sys.argv[2])
    # Or with 2 arguments: script.py file.json
    else:
        log_progress(sys.argv[1])
