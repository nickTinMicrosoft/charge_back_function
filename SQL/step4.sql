CREATE proc dbo.sp_update_usage_history
as

insert into usage_history_tbl
	select  cpu.DATABASE_NAME,
		CPU_SECONDS,
		IO_MB,
		MEM_MB,
		storage_type,
		size_mb,
		getdate() as load_date

from vw_cpu [cpu]
	join vw_io [io]
	on [io].DATABASE_NAME = [cpu].DATABASE_NAME

	join vw_buffer [buffer]
	on buffer.DATABASE_NAME = cpu.DATABASE_NAME

	join vw_storage [storage]
	on storage.database_name = cpu.DATABASE_NAME


where  cpu.DATABASE_NAME not in ('master', 'model', 'msdb') --,'usage_history')   --remove to exclude the usage_history table from the calculations
group by cpu.DATABASE_NAME, CPU_SECONDS, IO_MB, MEM_MB,storage_type, size_mb
order by cpu.DATABASE_NAME;



USE [usage_history_orig]
GO

/****** Object:  StoredProcedure [dbo].[sp_insert_environment_data]    Script Date: 7/26/2023 1:16:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


Create PROCEDURE [dbo].[sp_insert_environment_data] (@JsonData NVARCHAR(MAX))
AS
BEGIN

Insert INTO dbo.environment_info (mi_name, database_name, subscription_name, resource_group,tag_name,tag_value, date_updated, current_bit)
SELECT j.[ManagedInstance], j.[Database], j.[SubscriptionName], j.[ResourceGroupName], j.[TagName], j.[TagValue], getdate() as date_updated, 1 as current_bit
FROM OPENJSON(@jsonData) WITH (
    [ManagedInstance] NVARCHAR(100),
    [Database] NVARCHAR(100),
	[SubscriptionName] nvarchar(100),
	[ResourceGroupName] nvarchar(100),
	[TagName] NVARCHAR(100),
    [TagValue] NVARCHAR(100)
    
) AS j

end;
GO

