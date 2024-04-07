SELECT
  ZOBJECT.Z_PK AS event_id,
  datetime(ZOBJECT.ZCREATIONDATE+978307200,'UNIXEPOCH', 'LOCALTIME') AS event_datetime, 
  CASE ZOBJECT.ZSTARTDAYOFWEEK 
      WHEN "1" THEN "Sunday"
      WHEN "2" THEN "Monday"
      WHEN "3" THEN "Tuesday"
      WHEN "4" THEN "Wednesday"
      WHEN "5" THEN "Thursday"
      WHEN "6" THEN "Friday"
      WHEN "7" THEN "Saturday"
  END AS event_dow,
  ZOBJECT.ZSECONDSFROMGMT/3600 AS event_gtm_offset,
  datetime(ZOBJECT.ZSTARTDATE+978307200,'UNIXEPOCH', 'LOCALTIME') AS event_start, 
  datetime(ZOBJECT.ZENDDATE+978307200,'UNIXEPOCH', 'LOCALTIME') AS event_end, 
  (ZOBJECT.ZENDDATE-ZOBJECT.ZSTARTDATE) AS event_duration,
  ZOBJECT.ZSTREAMNAME AS event_type, 
  ZOBJECT.ZVALUESTRING AS event_description,

  ZOBJECT.ZHASCUSTOMMETADATA AS has_custom_md, 
  ZCUSTOMMETADATA.ZNAME AS custom_md_name,
  ZCUSTOMMETADATA.ZDOUBLEVALUE AS custom_md_double_value,
  ZCUSTOMMETADATA.ZSTRINGVALUE AS custom_md_string_value,
  ZOBJECT.ZHASSTRUCTUREDMETADATA AS has_structured_md, 
  ZSTRUCTUREDMETADATA.Z_DKINTENTMETADATAKEY__INTENTVERB AS structured_md_intent_verb, 
  ZSTRUCTUREDMETADATA.Z_DKINTENTMETADATAKEY__INTENTCLASS AS structured_md_intent_class, 
  ZSTRUCTUREDMETADATA.Z_DKINTENTMETADATAKEY__DERIVEDINTENTIDENTIFIER AS structured_md_derived_intent_id,
  ZSTRUCTUREDMETADATA.Z_CDENTITYMETADATAKEY__NAME AS structured_md_entity_name,
  ZSTRUCTUREDMETADATA.Z_DKNOTIFICATIONUSAGEMETADATAKEY__BUNDLEID AS structured_md_bundle_id,
  HEX(ZSTRUCTUREDMETADATA.Z_DKINTENTMETADATAKEY__SERIALIZEDINTERACTION) AS structured_md_serialized_interaction,
  --ZOBJECT.ZSTRING AS event_zstring, 
  ZOBJECT.ZVALUECLASS AS event_valueclass, 
  ZSOURCE.ZDEVICEID AS source_dev_id ,
  ZSOURCE.ZGROUPID as source_group_id,
  ZSOURCE.ZITEMID AS source_item_id,
  ZSOURCE.ZBUNDLEID AS  source_boundle_id,
  CURRENT_TIMESTAMP AS extraction_dt
FROM ZOBJECT
  LEFT JOIN ZSOURCE ON ZOBJECT.ZSOURCE  = ZSOURCE.Z_PK
  LEFT JOIN ZSTRUCTUREDMETADATA ON ZOBJECT.ZSTRUCTUREDMETADATA = ZSTRUCTUREDMETADATA.Z_PK
  LEFT JOIN Z_4EVENT ON ZOBJECT.Z_PK = Z_4EVENT.Z_11EVENT
  LEFT JOIN ZCUSTOMMETADATA ON Z_4EVENT.Z_4CUSTOMMETADATA = ZCUSTOMMETADATA.Z_PK