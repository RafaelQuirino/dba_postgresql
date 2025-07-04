-- Query for ownership (pg_catalog)
SELECT n.nspname as "Schema",
  c.relname as "Name",
  CASE c.relkind 
  	WHEN 'r' THEN 'table' 
  	WHEN 'v' THEN 'view' 
  	WHEN 'm' THEN 'materialized view' 
  	WHEN 'i' THEN 'index' 
  	WHEN 'S' THEN 'sequence' 
  	WHEN 't' THEN 'TOAST table' 
  	WHEN 'f' THEN 'foreign table' 
  	WHEN 'p' THEN 'partitioned table' 
  	WHEN 'I' THEN 'partitioned index' END as "Type",
  pg_catalog.pg_get_userbyid(c.relowner) as "Owner"
FROM pg_catalog.pg_class c
     LEFT JOIN pg_catalog.pg_namespace n 
         ON n.oid = c.relnamespace
     LEFT JOIN pg_catalog.pg_am am 
         ON am.oid = c.relam
WHERE c.relkind IN ('r','p','v','m','S','f','')
      AND n.nspname <> 'pg_catalog'
      AND n.nspname !~ '^pg_toast'
      AND n.nspname <> 'information_schema'
  AND pg_catalog.pg_table_is_visible(c.oid)
ORDER BY 1,2;