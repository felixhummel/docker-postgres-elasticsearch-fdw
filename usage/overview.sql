-- SELECT * FROM pg_catalog.pg_foreign_server;
SELECT c.relname as name,
       s.srvname as server_name,
       s.oid as server_id,
       ft.ftoptions
FROM pg_catalog.pg_foreign_table ft
INNER JOIN pg_catalog.pg_class c ON ft.ftrelid = c.oid
INNER JOIN pg_catalog.pg_foreign_server s ON ft.ftserver = s.oid
;
