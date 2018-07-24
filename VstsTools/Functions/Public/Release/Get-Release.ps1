function Get-Release {
    [CmdletBinding()]
    param (
        #Parameter Description
        [Parameter(Mandatory=$true)]
        [string]$ProjectName,

        #Parameter Description
        [Parameter(Mandatory=$true, ParameterSetName="Id")]
        [string]$ReleaseId,

        #Parameter Description
        [Parameter(Mandatory=$true, ParameterSetName="Name")]
        [string]$ReleaseName,

        #Parameter Description
        [Parameter(Mandatory=$true, ParameterSetName="Name")]
        [string]$ReleaseDefinitionName,

        #The Visual Studio Team Services account name
        [Parameter(Mandatory=$true)]
        [string]$Instance,

        #A PAT token with the necessary scope to invoke the requested HttpMethod on the specified Resource
        [Parameter(Mandatory=$true)]
        [string]$PatToken
    )

    process {

        if ($ReleaseName -ne "" -and $ReleaseName -ne $null) {

            $GetReleaseListParams = @{
                Instance = $Instance
                PatToken = $PatToken
                Collection = $ProjectName
                Area = "release"
                Resource = "releases"
                ApiVersion = "4.1-preview.6"
                ReleaseManager = $true
            }

            $ReleaseList = Invoke-VstsRestMethod @GetReleaseListParams

            $ReleaseId = ($ReleaseList.value | Where-Object {$_.name -eq $ReleaseName -and $_.releaseDefinition.name -eq $ReleaseDefinitionName}).id

        }

        $GetReleaseParams = @{
            Instance = $Instance
            PatToken = $PatToken
            Collection = $ProjectName
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

        $Release.ReleaseId = $ReleaseJson.id
        $Release.ReleaseName = $ReleaseJson.name
        $Release.CreatedOn = $ReleaseJson.createdOn
        $Release.ReleaseDefintionId = $ReleaseJson.releaseDefinition.id
        $Release.ReleaseDefintionName = $ReleaseJson.releaseDefinition.name
        $Release.Artifacts = $ReleaseJson.artifacts

        $Release

    }
}