create table dbo.usage_history_tbl
(
	history_id int primary key identity(1,1)
	,[database_name] varchar(300)
	,cpu_seconds int
	,io_mb int
	,mem_mb int
	,storage_type varchar(400)
	,size_mb float
	,load_date datetime2

);

create table dbo.environment_info
(
	table_id int primary key identity(1,1)
	,mi_name varchar(600)
	,[database_name] varchar(600)
	,[subscription_name] varchar(1000)
	,[resource_group] varchar(1000)
	,[tag_name] varchar(1000)
	,[tag_value] varchar(1000)
	,date_updated datetime2
	,current_bit bit

);