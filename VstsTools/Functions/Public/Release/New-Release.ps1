function New-Release {
    [CmdletBinding()]
    param (
        #Parameter Description
        [Parameter(Mandatory=$true)]
        [string]$ProjectName,

        #Parameter Description
        [Parameter(Mandatory=$true, ParameterSetName="Name")]
        [string]$ReleaseDefinitionId,

        #The Visual Studio Team Services account name
        [Parameter(Mandatory=$true)]
        [string]$Instance,

        #A PAT token with the necessary scope to invoke the requested HttpMethod on the specified Resource
        [Parameter(Mandatory=$true)]
        [string]$PatToken
    )

    process {

        $Body = @{
            definitionId = $ReleaseDefinitionId
            isDraft = $false
            reason = "Requested via API call"   
            manualEnvironments = $null       
        }

        $NewReleaseParams = @{
            Instance = $Instance
            PatToken = $PatToken
            Collection = $ProjectName
            Area = "release"
            Resource = "releases"
            ApiVersion = "5.0"
            ReleaseManager = $true
            HttpMethod = "POST"
            HttpBody = $Body
        }

        $ReleaseJson = Invoke-VstsRestMethod @NewReleaseParams

        $Release = New-ReleaseObject -ReleaseJson $ReleaseJson

        $Release

    }

}