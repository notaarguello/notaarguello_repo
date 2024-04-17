import duckdb

from typing import Optional
from mac_and_iphone_screentime_exporter.services.sqlite_to_duckdb import backup_sqlite_db
from mac_and_iphone_screentime_exporter.value_items import * 


def build_create_table_from_query(table_name:str, query:str):
    return f"CREATE OR REPLACE TABLE {table_name} AS {query}"


def knowledgec_full_update(
        sqlite_orig_path:Optional[str]=DEFAULT_KNOWLEDGE_DB_SOURCE_PATH, 
        duckdb_dest_path:Optional[str]=DEFAULT_DUCKDB_DUMP_PATH):
    
    backup_sqlite_db(
        sqlite_orig_path=sqlite_orig_path,
        duckdb_dest_path=duckdb_dest_path,
        duckdb_dest_tbl="knowledgeCdb_all_events",
        query=ALL_QUERIES["get_all_events"],
        incremental_on=("event_id", "extraction_dt"))

    con = duckdb.connect(duckdb_dest_path)

    for q_name in ("daily_summary", "screen_time_by_category_daily_totals", "screen_time_by_category_hourly_totals"):
        query=ALL_QUERIES[q_name]
        if q_name in ("screen_time_by_category_daily_totals", "screen_time_by_category_hourly_totals"):
            query = query.format(event_description_categorization=EVENT_CATEGORIZATION_FILEPATH)
        con.sql(build_create_table_from_query(table_name=q_name, query=query))

    