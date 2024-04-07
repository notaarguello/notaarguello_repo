WITH events AS (
    SELECT 
        event_start::DATE AS event_date, 
        event_dow,
        date_part('hour', event_start::DATETIME) event_hour,
        event_description, 
        CASE WHEN source_dev_id IS NULL THEN 'MAC' ELSE 'IPHONE' END AS device_type,
        event_duration
    FROM knowledgeCdb_all_events 
    WHERE event_type = '/app/usage'
)
SELECT
    events.event_date,
    events.event_dow,
    events.event_hour,
    COALESCE(categories.event_category, 'OTHER') AS event_category,
    events.device_type,
    sum(events.event_duration)/60 AS total_screen_time,
    count(1) AS event_count
FROM events
    LEFT JOIN read_csv("{event_description_categorization}") categories
        ON categories.event_description = events.event_description AND (categories.device_type = events.device_type OR categories.device_type IS NULL)
GROUP BY
    1, 2, 3, 4, 5