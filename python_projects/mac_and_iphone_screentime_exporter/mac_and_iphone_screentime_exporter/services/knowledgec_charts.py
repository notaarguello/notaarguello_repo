import duckdb
import os
import seaborn as sns
import matplotlib.pyplot as plt

from typing import Optional
from mac_and_iphone_screentime_exporter.value_items import DEFAULT_IO_PATH, DEFAULT_DUCKDB_DUMP_PATH



def gen_hourly_screentime_heatmap(
        yearmonth:int, img_destination:Optional[str]=None, db_path:Optional[str]=DEFAULT_DUCKDB_DUMP_PATH):

    con = duckdb.connect(database=db_path)
    df = con.sql(f"""
        SELECT strftime(event_date, '%m-%d %a') event_date, total_screen_time
        FROM daily_summary 
        WHERE device_type = 'IPHONE'
            AND strftime(event_date, '%Y%m')::INT={yearmonth}
        """
    ).df()
    pivot_df = df.pivot(index='event_date', columns='event_hour', values='total_screen_time')

    plt.figure(figsize=(12, 7.5))
    sns.heatmap(pivot_df, cmap="BuPu", linewidths=.01, annot=False, cbar=False)
    plt.ylabel("")
    plt.xlabel("")
    plt.tight_layout()

    img_destination = img_destination if img_destination else os.path.join(DEFAULT_IO_PATH, f"screentime_heatmap_{yearmonth}.png")
    plt.savefig(img_destination)
    plt.close()


def gen_daily_screentime_barchart(
        yearmonth:int, img_destination:Optional[str]=None, db_path:Optional[str]=DEFAULT_DUCKDB_DUMP_PATH):

    con = duckdb.connect(database=db_path)
    df = con.sql(f"""
        SELECT strftime(event_date, '%m-%d %a') event_date, total_screen_time
        FROM daily_summary 
        WHERE device_type = 'IPHONE'
            AND strftime(event_date, '%Y%m')::INT={yearmonth}"""
    ).df()
    plt.figure(figsize=(12, 4))
    sns.barplot(x='event_date', y='total_screen_time', data=df, color="powderblue")
    sns.despine(left=True, bottom=True)
    plt.ylabel("")
    plt.xlabel("")
    plt.xticks(rotation=45)
    plt.tight_layout()

    img_destination = img_destination if img_destination else os.path.join(DEFAULT_IO_PATH, f"screentime_barchart_{yearmonth}.png")
    plt.savefig(img_destination)
    plt.close()