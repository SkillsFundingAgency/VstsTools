function Get-Build {
<#
    .NOTES
    API Reference Get: https://docs.microsoft.com/en-us/rest/api/vsts/build/builds/get?view=vsts-rest-5.0
    API Reference List: https://docs.microsoft.com/en-gb/rest/api/azure/devops/build/builds/list?view=azure-devops-rest-5.0
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
        [Parameter(Mandatory=$true, ParameterSetName="Id")]
        [int]$BuildId,

        #The branch name, for git repos must be in the full reference, eg refs/heads/master rather than master
        [Parameter(Mandatory=$true, ParameterSetName="BranchName")]
        [string]$BranchName,

        #Parameter Description
        [Parameter(Mandatory=$true, ParameterSetName="BranchName")]
        [int]$BuildDefinitionId

    )
    
    process {

        $GetBuildParams = @{
            Instance = $Instance
            PatToken = $PatToken
            Collection = $ProjectId
            Area = "build"
            Resource = "builds"
            ApiVersion = "5.0"
        }

        if ($PSCmdlet.ParameterSetName -eq "Id") {

            $GetBuildParams["ResourceId"] = $BuildId

        }
        elseif ($PSCmdlet.ParameterSetName -eq "BranchName") {

            $GetBuildParams["AdditionalUriParameters"] = @{
                definitions = $BuildDefinitionId
                branchName = $BranchName
            }

        }

        $BuildJson = Invoke-VstsRestMethod @GetBuildParams

        if ($BuildJson.count -eq 1) {

            ##TO DO: return an array (this will break other functions)
            $Build = New-BuildObject -BuildJson $BuildJson.value

            return $Build

        }
        elseif ($BuildJson.count -gt 1) {

            $Builds = @()

            foreach ($Build in $BuildJson.value) {

                $Builds += New-BuildObject -BuildJson $Build

            }

            return $Builds | Sort-Object -Property QueueTime -Descending

        }
        elseif ($BuildJson | Get-Member -Name buildNumber) {
            
            $Build = New-BuildObject -BuildJson $BuildJson

        }
        else {

            throw "No builds matched the supplied parameters"

        }

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

        $Build.BuildId = $BuildJson.id
        $Build.BuildNumber = $BuildJson.buildNumber
        $Build.BranchName = $BuildJson.sourceBranch
        $Build.BuildDefinitionName = $BuildJson.definition.name
        $Build.DefintionId = $BuildJson.definition.id
        $Build.QueueTime = $BuildJson.queueTime
        if ($BuildJson.repository.type -eq "GitHub") {

            $Build.RepositoryId = $BuildJson.repository.id

        }
        elseif ($BuildJson.repository.type -eq "TfsGit") {

            $Build.RepositoryId = $BuildJson.repository.id
            $Build.RepositoryName = $BuildJson.repository.name

        }

        $Build
    
    }
}