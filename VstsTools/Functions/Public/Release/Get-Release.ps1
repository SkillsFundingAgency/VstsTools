function Get-Release {
    [CmdletBinding()]
    param (
        #Parameter Description
        [Parameter(Mandatory=$true)]
        [string]$ProjectName, 

        #Parameter Description
        [Parameter(Mandatory=$true)]
        [string]$ReleaseId, 

        #The Visual Studio Team Services account name
        [Parameter(Mandatory=$true)]
        [string]$Instance,
        
        #A PAT token with the necessary scope to invoke the requested HttpMethod on the specified Resource
        [Parameter(Mandatory=$true)]
        [string]$PatToken        
    )
    
    process {

        $GetReleaseParams = @{
            Instance = $Instance
            PatToken = $PatToken
            Collection = $Project.id
            Area = "release"
            Resource = "releases"
            ResourceId = $ReleaseId
            ApiVersion = "5.0-preview.7"
            ReleaseManager = $true
        }

        $ReleaseJson = Invoke-VstsRestMethod @GetReleaseParams

        $Release = New-ReleaseObject -ReleaseJson $ReleaseJson

        $Release

    }
    
}

function New-ReleaseObject {
    param(
        $ReleaseJson        
    )

    # Check that the object is not a collection
    if (!($ReleaseJson | Get-Member -Name count)) {

        $Release = New-Object -TypeName Release

        $Release.ReleaseId = $ReleaseJson.release.id
        $Release.ReleaseName = $ReleaseJson.release.name
        $Release.ReleaseDefintionId = $ReleaseJson.releaseDefinition.id
        $Release.ReleaseDefintionName = $ReleaseJson.releaseDefinition.name
        $Release.Artifacts = $ReleaseJson.artifacts

        $Release
    
    }
}