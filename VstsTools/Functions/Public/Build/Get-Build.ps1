function Get-Build {
<#
    .NOTES
    API Reference: https://docs.microsoft.com/en-us/rest/api/vsts/build/builds/get?view=vsts-rest-5.0
#>
    [CmdletBinding()]
    param (
        #The Visual Studio Team Services account name
        [Parameter(Mandatory=$true)]
        [string]$Instance,
        
        #A PAT token with the necessary scope to invoke the requested HttpMethod on the specified Resource
        [Parameter(Mandatory=$true)]
        [string]$PatToken,   

        #Parameter Description
        [Parameter(Mandatory=$true)]
        [string]$ProjectId,

        #Parameter Description
        [Parameter(Mandatory=$true)]
        [string]$BuildId      
    )
    
    process {

        $GetBuildParams = @{
            Instance = $Instance
            PatToken = $PatToken
            Collection = $ProjectId
            Area = "build"
            Resource = "builds"
            ResourceId = $BuildId
            ApiVersion = "4.1"
        }

        $BuildJson = Invoke-VstsRestMethod @GetBuildParams

        $Build = New-BuildObject -BuildJson $BuildJson

        $Build
    }

}

function New-BuildObject {
    param(
        $BuildJson
    )

    # Check that the object is not a collection
    if (!($BuildJson | Get-Member -Name count)) {

        $Build = New-Object -TypeName Build

        $Build.DefintionId = $BuildJson.definition.id
        $Build.BuildDefinitionName = $BuildJson.definition.name
        $Build.BuildNumber = $BuildJson.buildNumber
        $Build.RepositoryId = $BuildJson.repository.id
        $Build.RepositoryName = $BuildJson.repository.name

        $Build
    
    }
}