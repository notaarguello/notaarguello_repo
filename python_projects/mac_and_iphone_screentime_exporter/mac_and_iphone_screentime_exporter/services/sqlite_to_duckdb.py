import sqlite3
import pandas as pd
import duckdb

from typing import Optional


def sqlite_query_and_fetchall(sqlite_db_path:str, query:str) -> pd.DataFrame:
    sqlite_conn = sqlite3.connect(sqlite_db_path)
    return pd.read_sql_query(query, sqlite_conn)

def backup_sqlite_db(
        sqlite_orig_path:str, duckdb_dest_path:str, 
        duckdb_dest_tbl:str, query:str, incremental_on:Optional[tuple[str, str]]=None):
    
    df_sqlite_export = sqlite_query_and_fetchall(sqlite_db_path=sqlite_orig_path, query=query)
    duckdb_con = duckdb.connect(duckdb_dest_path)

    if duckdb_dest_tbl not in duckdb_con.sql("SELECT table_name FROM duckdb_tables;").df()["table_name"].to_list():

        duckdb_con.sql(f"CREATE TABLE {duckdb_dest_tbl} AS SELECT * FROM df_sqlite_export;")
    else:
        duckdb_con.sql(f"CREATE OR REPLACE TABLE {duckdb_dest_tbl}_stg AS SELECT * FROM df_sqlite_export;")
        
        
        if incremental_on :
            (inc_key, inc_ord) = incremental_on
            qualify_clause = f"QUALIFY row_number() OVER (PARTITION BY {inc_key} ORDER BY {inc_ord} DESC) = 1"
        else:
            qualify_clause = ""
        duckdb_con.sql(f"CREATE TABLE {duckdb_dest_tbl}_new AS SELECT * FROM (SELECT * FROM {duckdb_dest_tbl}_stg UNION ALL SELECT * FROM {duckdb_dest_tbl}) AS stg_and_old {qualify_clause};")
        duckdb_con.sql(f"DROP TABLE IF EXISTS {duckdb_dest_tbl}_stg;")
        duckdb_con.sql(f"DROP TABLE IF EXISTS {duckdb_dest_tbl};")
        duckdb_con.sql(f"ALTER TABLE {duckdb_dest_tbl}_new RENAME TO {duckdb_dest_tbl}_old;")