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

