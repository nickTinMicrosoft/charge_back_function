create view dbo.vw_io
as
select db_name(database_id) as [DATABASE_NAME],
	sum((num_of_bytes_read + num_of_bytes_written)/1048576) as IO_MB
from sys.dm_io_virtual_file_stats (NULL, NULL)
group by [database_id];