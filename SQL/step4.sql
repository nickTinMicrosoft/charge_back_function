create view dbo.vw_buffer
as
Select [DATABASE_NAME] = 
	CASE WHEN database_id = 32767 
	THEN 'RESOURCEDB'ELSE DB_NAME(database_id) END,
	MEM_MB = COUNT(1)/128
FROM sys.dm_os_buffer_descriptors
Group By [database_id]; 
