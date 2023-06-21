using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$name = $Request.Query.Name
if (-not $name) {
    $name = $Request.Body.Name
}

$action = $Request.Query.Action
if(-not $action){
    $action = $Request.Body.Action
}

# {
#     "Admin":"Test",
#     "Password":"Test Two"
# }



function Execute-SQL{
    param(
        $query
    )
    $userName = $env:USER_NAME
    $password = $env:USER_PASSWORD

    $dbConnection = new-object System.Data.SqlClient.SqlConnection
    $dbConnection.ConnectionString = "Data Source=tcp:tins-sqlmi-demo.public.21bf3cd12c20.database.windows.net,3342;Initial Catalog=usage_history;User ID=$userName;Password=$password"
    $dbConnection.open()

    ##command
    $sqlCommand = new-object System.Data.SqlClient.SqlCommand 
    $sqlCommand.Connection = $dbConnection
    $sqlCommand.CommandText = $query
    # $sqlCommand.Parameters.AddWithValue("@JsonData", $csv)
    # $sqlCommand.Parameters = $jsonData
    ##exicute proc
    $sqlCommand.ExecuteNonQuery()
    $dbConnection.Close()

}

if($action -eq "get"){
    Import-Module Az.Accounts
    Import-Module Az.Sql

    $resourceGroupName =  $env:RESOURCE_GROUP
    $managedInstanceName = $env:MANAGED_INSTANCE_NAME

    #connect to Azure and get subscription information
    Connect-AzAccount -Identity
    $context = Get-AzContext
    $subscriptionId = $context.Subscription.Id
    $managedInstance = Get-AzSqlInstance -ResourceGroupName $resourceGroupName -Name $managedInstanceName 
    $databases = Get-AzSqlInstanceDatabase -ResourceGroupName $resourceGroupName -InstanceName $managedInstanceName

    # build ouput objects
    $miArray = Get-AzSqlInstance | Select-Object -ExpandProperty ManagedInstanceName # Initialize an array to store the database tags
    $tagArray = @() # Loop through each Azure SQL Managed Instance
    foreach ($mi in $miArray) {
        # Get all databases in the managed instance
        $dbArray = Get-AzSqlInstanceDatabase -InstanceName $mi -ResourceGroup $resourceGroupName | Select-Object -ExpandProperty Name     # Loop through each database in the managed instance
        foreach ($db in $dbArray) {
            # Get the tags for the database
            $tags = (Get-AzSqlInstanceDatabase -InstanceName $mi -Name $db -ResourceGroup $resourceGroupName).Tags         # Loop through each tag and add it to the tag array
            foreach ($tag in $tags.GetEnumerator()) {
                    $tagArray += New-Object PSObject -Property @{
                    Database = $db
                    ManagedInstance = $mi
                    SubscriptionName = $subscriptionId
                    ResourceGroupName = $resourceGroupName
                    TagName = $tag.Key
                    TagValue = $tag.Value
                }
            }
        }
    }

    #convert objects to JSON
    $csv = ($tagArray | ConvertTo-Json) -join [Environment]::NewLine # Convert the file to a byte array
    Write-Host $csv


    #setup login to SQL MI
    $userName = $env:SQL_USER_NAME
    $password = $env:SQL_USER_PASSWORD

    # ##connect to db
    $dbConnection = new-object System.Data.SqlClient.SqlConnection
    $dbConnection.ConnectionString = "Data Source=tcp:tins-sqlmi-demo.public.21bf3cd12c20.database.windows.net,3342;Initial Catalog=usage_history;User ID=$userName;Password=$password"
    $dbConnection.open()
    ##command
    $sqlCommand = new-object System.Data.SqlClient.SqlCommand 
    $sqlCommand.Connection = $dbConnection
    $sqlCommand.CommandText = "Exec sp_insert_environment_data @JsonData"
    $sqlCommand.Parameters.AddWithValue("@JsonData", $csv)
    # $sqlCommand.Parameters = $jsonData
    ##exicute proc
    $sqlCommand.ExecuteNonQuery()
    $dbConnection.Close()

    $body = "Executed Get Environment Function"

}

if($action -eq "truncate"){
    $body = "Truncate Environment Table"
    Execute-SQL -query "Truncate Table dbo.environment_info"
}


if ($name) {
    $body = "Hello, $name. This HTTP triggered function executed successfully."
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})
