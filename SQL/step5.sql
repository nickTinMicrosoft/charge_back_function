create view dbo.vw_storage
as
SELECT [database_name] = DB_NAME(database_id),
     [storage_type] = CASE WHEN Type_Desc = 'ROWS' 
				THEN 'Data File(s)'
              WHEN Type_Desc = 'LOG'  
				THEN 'Log File(s)'
			  WHEN Type_desc is null
				THEN 'Combined'
              ELSE Type_Desc END,
     [size_mb] = CAST( ((SUM(Size)* 8) / 1024.0) AS DECIMAL(18,2) )
FROM   sys.master_files
where DB_NAME(database_id) not in ('master','msdb','tempdb', 'model')
GROUP BY  GROUPING SETS
        (
               (DB_NAME(database_id), Type_Desc),
               (DB_NAME(database_id))
        );