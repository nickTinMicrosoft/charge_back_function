create view dbo.vw_cpu
as
select db_name(pa.database_id) as [DATABASE_NAME], sum(qs.total_worker_time/qs.execution_count)/1000 as CPU_SECONDS 
from sys.dm_exec_query_stats qs
	cross apply(select convert (int,value) as [Database_id]	
	from sys.dm_exec_plan_attributes(qs.plan_handle) pa
	WHERE attribute = N'dbid') pa
group by [database_id];