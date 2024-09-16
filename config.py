import os
from dotenv import load_dotenv

load_dotenv()

def get_env_var(key):
    return os.getenv(key)
