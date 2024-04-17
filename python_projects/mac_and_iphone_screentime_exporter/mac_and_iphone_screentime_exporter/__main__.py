import click
import logging

from datetime import datetime

from mac_and_iphone_screentime_exporter.value_items import DEFAULT_KNOWLEDGE_DB_SOURCE_PATH, DEFAULT_DUCKDB_DUMP_PATH, DEFAULT_LOGS_PATH
from mac_and_iphone_screentime_exporter.services.knowledgec_full_update import knowledgec_full_update
from mac_and_iphone_screentime_exporter.services.knowledgec_charts import gen_hourly_screentime_heatmap, gen_daily_screentime_barchart


logging.basicConfig(filename=DEFAULT_LOGS_PATH, filemode='a', level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Defining the CLI command and its options using Click
@click.command()
@click.option('--sqlite-orig-path', default=DEFAULT_KNOWLEDGE_DB_SOURCE_PATH, help='Path to the original SQLite database.')
@click.option('--duckdb-dest-path', default=DEFAULT_DUCKDB_DUMP_PATH, help='Path to the destination DuckDB dump.')
def knowledgec_update(sqlite_orig_path, duckdb_dest_path):
    """
    This command updates the the knowledgec tables from your sqlite data.
    You can specify custom paths for both the original SQLite database and the DuckDB dump.
    If paths are not specified, default values are used.
    """
    logging.info("Starting knowledgec update process...")
    knowledgec_full_update(sqlite_orig_path=sqlite_orig_path, duckdb_dest_path=duckdb_dest_path)
    logging.info("Database update completed.")
    logging.info("Generating charts update completed.")
    current_year_month_int = int(datetime.now().strftime("%Y%m"))
    gen_hourly_screentime_heatmap(yearmonth=current_year_month_int)
    gen_daily_screentime_barchart(yearmonth=current_year_month_int)


if __name__ == '__main__':
    knowledgec_update()