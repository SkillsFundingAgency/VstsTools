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
        [string]$ReleaseEnvironment,

        ##TO DO: implement ParameterSet to make a selector \ filter mandatory

        #Parameter Description
        [Parameter(Mandatory=$false)]
        [switch]$MostRecentDeployment
    )
    
    process {
        
        $GetDeploymentsListParams = @{
            Instance = $Instance
            PatToken = $PatToken
            Collection = $ProjectId
            Area = "release"
            Resource = "deployments"
            ApiVersion = "4.1-preview.2"
            ReleaseManager = $true
        }

        $DeploymentsList = (Invoke-VstsRestMethod @GetDeploymentsListParams).value

        if($MostRecentDeployment.IsPresent) {

            # Filter by status and environment, sort by date, select top 1
            $DeploymentJson = $DeploymentsList | Where-Object {$_.deploymentStatus -eq "succeeded"} | Where-Object {$_.releaseEnvironment.name -eq $ReleaseEnvironment} | Sort-Object -Property completedOn -Descending | Select-Object -First 1
            ##TO DO: handle no matching $ReleaseEnvironment
            $Deployment = New-DeploymentObject -DeploymentJson $DeploymentJson
            $Deployment
        
        }
        
        ##TO DO: implement other Release selectors / filters
            #Failed deployment
            #Release number
    }

}

function New-DeploymentObject {
    param (
        $DeploymentJson
    )
    
    # Check that the object is not a collection
    if (!($DeploymentJson | Get-Member -Name count)) {

        $Deployment = New-Object -TypeName Deployment

        $Deployment.ReleaseDefinition = $DeploymentJson.releaseDefinition.name
        $Deployment.ReleaseId = $DeploymentJson.release.id
        $Deployment.ReleaseName = $DeploymentJson.release.name
        $Deployment.Artifacts = $DeploymentJson.release.artifacts

        return $Deployment

    }
}