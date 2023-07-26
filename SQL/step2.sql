create view dbo.vw_cpu
as
select db_name(pa.database_id) as [DATABASE_NAME], sum(qs.total_worker_time/qs.execution_count)/1000 as CPU_SECONDS 
from sys.dm_exec_query_stats qs
	cross apply(select convert (int,value) as [Database_id]	
	from sys.dm_exec_plan_attributes(qs.plan_handle) pa
	WHERE attribute = N'dbid') pa
group by [database_id]
--order by CPU_SECONDS
;

--create view for IO
create view dbo.vw_io
as
select db_name(database_id) as [DATABASE_NAME],
	sum((num_of_bytes_read + num_of_bytes_written)/1048576) as IO_MB
from sys.dm_io_virtual_file_stats (NULL, NULL)
group by [database_id]
--order by IO_MB DESC
;

--create view for Buffer
create view dbo.vw_buffer
as
Select [DATABASE_NAME] = 
	CASE WHEN database_id = 32767 
	THEN 'RESOURCEDB'ELSE DB_NAME(database_id) END,
	MEM_MB = COUNT(1)/128
FROM sys.dm_os_buffer_descriptors
Group By [database_id]
--Order By 2 DESC
;


--Create View Storage
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
--Uncomment if you need to query for a particular database
--WHERE      database_id = DB_ID(‘Database Name’) 

where DB_NAME(database_id) not in ('master','msdb','tempdb', 'model')
GROUP BY  GROUPING SETS
        (
               (DB_NAME(database_id), Type_Desc),
               (DB_NAME(database_id))
        ) 

;



--step 2 create views