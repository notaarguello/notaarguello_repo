import os
from mac_and_iphone_screentime_exporter.utils import create_path_if_not_exists, parse_array_env_var


PROJECT_PATH = os.path.sep + os.path.join(
    *os.path.abspath(__file__).split(os.path.sep)[:-3]
)
IO_PATH = create_path_if_not_exists(os.path.join(PROJECT_PATH, 'io'))