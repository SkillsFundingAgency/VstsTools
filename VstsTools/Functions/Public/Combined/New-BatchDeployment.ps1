function New-BatchDeployment {
    [CmdletBinding()]
    param(
        #The environment name
        [Parameter(Mandatory=$true)]
        [string]$EnvironmentName, 
        
        #The path to a folder of release definitions with Azure DevOps Releases
        [Parameter(Mandatory=$true, ParameterSetName="Path")]
        [string]$ReleaseFolderPath,

        #An array of release names
         [Parameter(Mandatory=$true, ParameterSetName="Names")]
         [string[]]$ReleaseNames,       
   
        #Parameter Description
        [Parameter(Mandatory=$true)]
        [string]$ProjectName,

        #The Visual Studio Team Services account name
        [Parameter(Mandatory=$true)]
        [string]$Instance,

        #A PAT token with the necessary scope to invoke the requested HttpMethod on the specified Resource
        [Parameter(Mandatory=$true)]
        [string]$PatToken
    )

    if ($PSCmdlet.ParameterSetName -eq "Names") {

        ##TO DO: get each release defintion by name and add to a collection

    }
    elseif ($PSCmdlet.ParameterSetName -eq "Path") {
        
        ##TO DO: check where Get-ReleaseDefinition is used, decide whether to change return type for a single instance to array
        ##TO DO: modify Get-ReleaseDefinition to return more than 1 release
        ##TO DO: modify Get-ReleaseDefintion to use path as a searchText term / filter returned results by path
        ##TO DO: get a collection of releases by path

    }
    else {
        throw "Must specify an array of names or a path."
    }
}