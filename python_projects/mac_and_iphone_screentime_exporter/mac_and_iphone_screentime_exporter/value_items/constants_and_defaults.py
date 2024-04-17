import os
from mac_and_iphone_screentime_exporter.utils import create_path_if_not_exists, walk_dir, read_file_contents


PROJECT_PATH = os.path.sep + os.path.join(
    *os.path.abspath(__file__).split(os.path.sep)[:-3]
)

DEFAULT_IO_PATH = create_path_if_not_exists(os.path.join(PROJECT_PATH, "io"))
DEFAULT_LOGS_PATH = os.path.join(DEFAULT_IO_PATH, "logs.txt")
DEFAULT_DUCKDB_DUMP_PATH = os.path.join(DEFAULT_IO_PATH, "lifestats.db")
EVENT_CATEGORIZATION_FILEPATH = os.path.join(DEFAULT_IO_PATH, "csv_data", "event_description_categorization.csv")

DEFAULT_KNOWLEDGE_DB_SOURCE_PATH = os.path.join(os.path.expanduser("~"), "Library", "Application Support", "Knowledge", "knowledgeC.db")

_KNOWLEDGEC_QUERIES_PATH = os.path.join(PROJECT_PATH, "mac_and_iphone_screentime_exporter", "knowledgeC_queries")
ALL_QUERIES = {
    file_name[1].rsplit(".", 1)[0]: read_file_contents(file_full_path=os.path.join(*file_name))
    for file_name in walk_dir(dir_to_walk=_KNOWLEDGEC_QUERIES_PATH)
}