using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

$action = $Request.Query.Action
if(-not $action){
    $action = $Request.Body.Action
}

$admin_user = $Request.Body.Admin
$admin_password = $Request.Body.Password

if($action -eq "build"){
    $body = "Idea to build SQL DB, Tables, and Procs, under construction"
    #execute build Database

    $message = "User name $($admin_user) Password $($admin_password)"

    Write-Host $message



}



# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})
