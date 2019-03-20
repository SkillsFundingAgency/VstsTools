function New-Deployment {
    [CmdletBinding()]
    param (
        #The ReleaseEnvironmentId, the id of the environment within the release (as opposed to the id of the environment within the release definition)
        [Parameter(Mandatory=$true, ParameterSetName="Name")]
        [int]$EnvironmentId,
    
        #Parameter Description
        [Parameter(Mandatory=$true, ParameterSetName="Name")]
        [string]$ReleaseId,

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

    process {

        $Body = @{
            comment = "Requested via API call" 
            status = "inProgress"
        }

        $NewDeploymentParams = @{
            Instance = $Instance
            PatToken = $PatToken
            Collection = $ProjectName
            Area = "release"
            Resource = "releases"
            ResourceId = $ReleaseId
            ResourceComponent = "environments"
            ResourceComponentId = $EnvironmentId
            ApiVersion = "5.0-preview.6"
            ReleaseManager = $true
            HttpMethod = "PATCH"
            HttpBody = $Body
        }

        $DeploymentJson = Invoke-VstsRestMethod @NewDeploymentParams

        $ReleaseEnvironment = New-ReleaseEnvironmentObject -ReleaseEnvironmentJson $DeploymentJson

        $ReleaseEnvironment

    }

}