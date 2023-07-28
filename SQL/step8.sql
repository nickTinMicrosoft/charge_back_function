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