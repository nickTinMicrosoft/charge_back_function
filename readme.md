# Charge Back Function 
## developers: Luke Arp, Nick Tinsley, Jeff Nuckolls

# Deploy into Azure
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FnickTinMicrosoft%2Fcharge_back_function%2Fmaster%2Ffunction-app.json)

### Description:
Charge back Function app has three Functions:

* build-db
* get-tags-timer
* get-tags-http

# Under Construction
## build-db
### Requires Query Parameter: Action 
### Action options: build
Upon HTTP call to build-db function, with Query parameter Action set to "build", this function will connect to the SQL Managed instance that you want to use, use the SQL files to create usage_history database, the tables, stored procedures and views.   

#### Ex: function-app.com/Acrtion="build"

## get-tags-timer
### Powershell Script
Based on cron setting, this function runs constantly and will query the SQL Managed Instance environment in Azure, gather tags for each DB in SQL MI, and execute a SQL Proceduer in the usage_history db to save data into dbo.environment_info table.

## get-tags-http
### Requires Query Parameter: Action
### Action options: get, truncate

### Action: get
Will query the SQL Managed Instance environment in Azure, gather tags for each DB in SQL MI, and execute a SQL Proceduer in the usage_history db to save data into dbo.environment_info table.

### Action: truncate
If the SQL User supplied has ability to, this command will truncate the dbo.environment_info table. This is meant to clear the table to gather new tags. 



### Coming soon
* build-db further development
* keeping history of tags