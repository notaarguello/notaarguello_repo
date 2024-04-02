import os
import sqlite3
import pandas as pd
import duckdb

from typing import Optional


def query_and_fetchall(sqlite_db_path:str, query:str) -> pd.DataFrame:
    sqlite_conn = sqlite3.connect(sqlite_db_path)
    return pd.read_sql_query(query, sqlite_conn)

def backup_sqlite_db(
        sqlite_orig_path:str, duckdb_dest_path:str, 
        duckdb_dest_tbl:str, query:str, incremental_on:Optional[tuple[str, str]]=None):
    df_sqlite_export = query_and_fetchall(sqlite_db_path=sqlite_orig_path, query=query)
    duckdb_con = duckdb.connect("duckdb_dest_path")

    duckdb_con.sql(f"CREATE TABLE {duckdb_dest_tbl}_stg AS SELECT * FROM df_sqlite_export;")
    duckdb_con.sql(f"ALTER TABLE {duckdb_dest_tbl} RENAME TO {duckdb_dest_tbl}_old;")
    
    if incremental_on :
        (inc_key, inc_ord) = incremental_on
        qualify_clause = f"QUALIFY row_number() OVER (PARTITION BY {inc_key} ORDER BY {inc_ord} DESC) = 1"
    else:
        qualify_clause = ""
    duckdb_con.sql(f"CREATE TABLE {duckdb_dest_tbl} AS SELECT * FROM (SELECT * FROM {duckdb_dest_tbl}_stg UNION ALL {duckdb_dest_tbl}_old) AS stg_and_old {qualify_clause};")
