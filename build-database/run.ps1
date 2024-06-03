using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

$action = $Request.Query.Action
if(-not $action){
    $action = $Request.Body.Action
}

$userName = $env:SQL_USER_NAME
$password = $env:SQL_USER_PASSWORD
$connection_string = $env:SQL_CONNECTION_STRING


function Execute-SQL{
    param(
        $query
        ,$step
    )

    $dbConnection = new-object System.Data.SqlClient.SqlConnection
    if($step -eq 1){
        $dbConnection.ConnectionString = "Data Source=$connection_string;User ID=$userName;Password=$password"
    }
    else{
        $dbConnection.ConnectionString = "Data Source=$connection_string;Initial Catalog=usage_history;User ID=$userName;Password=$password"
    }
    
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

if($action -eq "build"){
    $body = "Idea to build SQL DB, Tables, and Procs, under construction"
    #execute build Database

    #get list of file names
    $path = '.\SQL'
    $fileList = Get-ChildItem -Path $path -File
    $step = 1

    foreach($file in $fileList){
        
        $text = Get-Content -Path "$($path)\$($file.Name)"
        Write-Host "executing SQL File: $($file.Name) Step $($step)"

        Execute-SQL -query $text -step $step

        $step = $step + 1

    }




}



# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})
