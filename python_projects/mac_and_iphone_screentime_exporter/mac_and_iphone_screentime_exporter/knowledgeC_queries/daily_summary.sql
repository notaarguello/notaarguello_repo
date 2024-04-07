WITH e_isbacklit AS (
    SELECT 
        event_start::DATE AS event_date, 
        event_dow,
        CASE WHEN source_dev_id IS NULL THEN 'MAC' ELSE 'IPHONE' END AS device_type,
        SUM(event_duration)/60 total_screen_time,
        COUNT(1) AS total_pick_ups,
        MAX(event_duration)/60 AS longest_pick_up
    FROM knowledgeCdb_all_events 
    WHERE event_type = '/display/isBacklit'
    GROUP BY 1, 2, 3
),

e_islocked AS (
    SELECT 
        event_start::DATE AS event_date, 
        CASE WHEN source_dev_id IS NULL THEN 'MAC' ELSE 'IPHONE' END AS device_type,
        MEDIAN(event_duration) AS median_time_between_unlocks,
        MAX(event_duration)/60 AS longest_locked_period
    FROM knowledgeCdb_all_events 
    WHERE event_type = '/device/isLocked'
    GROUP BY 1, 2
),

e_most_used_app_1 AS (
    SELECT
        event_start::DATE AS event_date, 
        CASE WHEN source_dev_id IS NULL THEN 'MAC' ELSE 'IPHONE' END AS device_type,
        event_description,
        SUM(event_duration)/60 total_screen_time,
        COUNT(1) AS total_pick_ups
    FROM knowledgeCdb_all_events 
    WHERE event_type = '/app/usage'
    GROUP BY 1, 2, 3
),

e_most_used_app_2 AS (
    SELECT
        event_date, 
        device_type,
        event_description,
        total_screen_time,
        total_pick_ups
    FROM e_most_used_app_1
    QUALIFY ROW_NUMBER() OVER (PARTITION BY event_date, device_type ORDER BY total_screen_time DESC) = 1
),

e_notifications AS (
    SELECT 
        event_start::DATE AS event_date,
        count(1) total_notifications_received
    FROM knowledgeCdb_all_events
    WHERE event_type = '/notification/usage'
        AND event_description = 'Receive'
        AND source_dev_id IS NOT NULL
    GROUP BY 1
),

e_delivery_apps AS (
    SELECT 
        event_start::DATE AS event_date
    FROM knowledgeCdb_all_events
    WHERE event_type = '/app/usage'
        AND event_description = 'com.pedidosya.PedidosYa-'
        AND source_dev_id IS NOT NULL
    GROUP BY 1
)
        
SELECT 
    e_isbacklit.event_date,
    e_isbacklit.event_dow,
    e_isbacklit.device_type,
    e_isbacklit.total_screen_time,
    AVG(e_isbacklit.total_screen_time) OVER (
        PARTITION BY e_isbacklit.device_type 
        ORDER BY e_isbacklit.event_date DESC
        RANGE BETWEEN INTERVAL 6 DAYS PRECEDING AND INTERVAL 0 DAYS FOLLOWING) total_screen_time_7d_avg,
    AVG(e_isbacklit.total_screen_time) OVER (
        PARTITION BY e_isbacklit.device_type 
        ORDER BY e_isbacklit.event_date DESC
        RANGE BETWEEN INTERVAL 27 DAYS PRECEDING AND INTERVAL 0 DAYS FOLLOWING) total_screen_time_28d_avg,
    e_isbacklit.total_pick_ups,
    e_isbacklit.longest_pick_up,
    e_islocked.median_time_between_unlocks,
    e_islocked.longest_locked_period,
    e_most_used_app_2.event_description AS most_used_app,
    e_most_used_app_2.total_screen_time AS most_used_app_total_screen_time,
    e_most_used_app_2.total_pick_ups AS most_used_app_total_pick_ups,
    e_notifications.total_notifications_received,
    CASE WHEN e_delivery_apps.event_date IS NOT NULL THEN 'Y' ELSE 'N' END used_food_delivery_apps,
    COUNT(e_delivery_apps.event_date) OVER (
        PARTITION BY e_isbacklit.device_type 
        ORDER BY e_isbacklit.event_date DESC
        RANGE BETWEEN INTERVAL 6 DAYS PRECEDING AND INTERVAL 0 DAYS FOLLOWING) used_food_delivery_apps_7d_cnt,
    COUNT(e_delivery_apps.event_date) OVER (
        PARTITION BY e_isbacklit.device_type 
        ORDER BY e_isbacklit.event_date DESC
        RANGE BETWEEN INTERVAL 27 DAYS PRECEDING AND INTERVAL 0 DAYS FOLLOWING) used_food_delivery_apps_28d_cnt,
FROM e_isbacklit
LEFT JOIN e_islocked ON 
    e_isbacklit.event_date = e_islocked.event_date AND 
    e_isbacklit.device_type = e_islocked.device_type
LEFT JOIN e_most_used_app_2 ON 
    e_isbacklit.event_date = e_most_used_app_2.event_date AND 
    e_isbacklit.device_type = e_most_used_app_2.device_type
LEFT JOIN e_notifications ON
    e_isbacklit.event_date = e_notifications.event_date AND 
    e_isbacklit.device_type = 'IPHONE'
LEFT JOIN e_delivery_apps ON 
    e_isbacklit.event_date = e_delivery_apps.event_date AND 
    e_isbacklit.device_type = 'IPHONE'
ORDER BY e_isbacklit.event_date, e_isbacklit.device_type