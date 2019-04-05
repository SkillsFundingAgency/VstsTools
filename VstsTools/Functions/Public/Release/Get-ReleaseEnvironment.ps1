function Get-ReleaseEnvironment {
    [CmdletBinding()]
    param (
        #Parameter Description
        [Parameter(Mandatory=$true)]
        [string]$EnvironmentName,    
    
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

        $ReleaseEnvironment = New-ReleaseEnvironmentObject -ReleaseEnvironmentJson ($ReleaseJson.environments | Where-Object {$_.name -eq $EnvironmentName})

        $ReleaseEnvironment

    }

}
function New-ReleaseEnvironmentObject {
    param(
        $ReleaseEnvironmentJson
    )

    # Check that the object is not a collection
    if (!($ReleaseEnvironmentJson | Get-Member -Name count)) {

        $ReleaseEnvironment = New-Object -TypeName ReleaseEnvironment

        $ReleaseEnvironment.Id = $ReleaseEnvironmentJson.id
        $ReleaseEnvironment.Name = $ReleaseEnvironmentJson.name
        $ReleaseEnvironment.Status = $ReleaseEnvironmentJson.status
        $ReleaseEnvironment.ReleaseId = $ReleaseEnvironmentJson.release.id
        $ReleaseEnvironment.ReleaseName = $ReleaseEnvironmentJson.release.name
        $ReleaseEnvironment.ReleaseDefintionId = $ReleaseEnvironmentJson.releaseDefinition.id
        $ReleaseEnvironment.ReleaseDefinitionName = $ReleaseEnvironmentJson.releaseDefinition.id

        $ReleaseEnvironment

    }
}