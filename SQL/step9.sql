create view [dbo].[vw_hist_with_environment]
as
select hist.[database_name]
	,cpu_seconds
	,io_mb
	,mem_mb
	,storage_type
	,size_mb
	,mi_name
	,tag_name
	,tag_value
 
from dbo.usage_history_tbl [hist]

	join dbo.environment_info [env]
	on env.[database_name] = hist.[database_name]

