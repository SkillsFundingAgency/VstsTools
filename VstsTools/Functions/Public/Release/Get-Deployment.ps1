function Get-Deployment {
<#
    .NOTES
    API Reference: https://docs.microsoft.com/en-us/rest/api/vsts/release/deployments/list
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
        [string]$ReleaseDefinitionName,

        #Parameter Description
        [Parameter(Mandatory=$true)]
        [string]$ReleaseEnvironment,

        #Parameter Description
        [Parameter(Mandatory=$true, ParameterSetName="ReleaseName")]
        [string]$ReleaseName,

        #Returns the most recent successful release to the specified environment
        [Parameter(Mandatory=$true, ParameterSetName="MostRecent")]
        [switch]$MostRecentDeployment
    )
    
    process {
        
        $ReleaseDefinition = Get-ReleaseDefinition -DefinitionName $ReleaseDefinitionName -ProjectId $ProjectId -Instance $Instance -PatToken $PatToken

        $GetDeploymentsListParams = @{
            Instance = $Instance
            PatToken = $PatToken
            Collection = $ProjectId
            Area = "release"
            Resource = "deployments"
            ApiVersion = "4.1-preview.2"
            ReleaseManager = $true
            AdditionalUriParameters = @{
                definitionId = $ReleaseDefinition.Id
            }
        }

        $DeploymentsList = (Invoke-VstsRestMethod @GetDeploymentsListParams).value

        if($MostRecentDeployment.IsPresent) {

            # Filter by status and environment, sort by date, select top 1
            $DeploymentJson = $DeploymentsList | Where-Object {$_.deploymentStatus -eq "succeeded"} | Where-Object {$_.releaseEnvironment.name -eq $ReleaseEnvironment} | Sort-Object -Property completedOn -Descending | Select-Object -First 1
            $Deployment = New-DeploymentObject -DeploymentJson $DeploymentJson -ReleaseEnvironment $ReleaseEnvironment
            $Deployment

        
        }
        elseif ($ReleaseName) {
            
            $DeploymentJson = $DeploymentsList | Where-Object {$_.deploymentStatus -eq "succeeded"} | Where-Object {$_.releaseEnvironment.name -eq $ReleaseEnvironment} | Where-Object {$_.release.name -eq $ReleaseName} | Sort-Object -Property completedOn -Descending | Select-Object -First 1
            $Deployment = New-DeploymentObject -DeploymentJson $DeploymentJson -ReleaseEnvironment $ReleaseEnvironment
            $Deployment

        }
        
    }

}

function New-DeploymentObject {
    param (
        $DeploymentJson,
        $ReleaseEnvironment
    )
    
    if($DeploymentJson) {
        # Check that the object is not a collection
        if (!($DeploymentJson | Get-Member -Name count)) {

            $Deployment = New-Object -TypeName Deployment

            $Deployment.ReleaseDefinition = $DeploymentJson.releaseDefinition.name
            $Deployment.ReleaseId = $DeploymentJson.release.id
            $Deployment.ReleaseName = $DeploymentJson.release.name
            $Deployment.CompletedOn = $DeploymentJson.completedOn
            $Deployment.Artifacts = $DeploymentJson.release.artifacts

            return $Deployment

        }
    }
    else {

        throw "Environment $ReleaseEnvironment not deployed."

    }
}