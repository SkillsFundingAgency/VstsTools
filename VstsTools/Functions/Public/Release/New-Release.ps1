<#
    .NOTES
    Requires a PAT token with the following permissions: Build (Read); Release (Read, write, & execute)
    
    API Reference: https://docs.microsoft.com/en-us/rest/api/azure/devops/release/releases/create?view=azure-devops-rest-5.0
#>
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
        [string]$PatToken,

        #(Optional) The name of the branch in the primary artefact that will be released.  If not specified then the default version for the primary artefact will be used.
        [Parameter(Mandatory=$false)]    
        [string]$PrimaryArtifactBranchName
    )

    process {

        $Body = @{
            definitionId = $ReleaseDefinitionId
            isDraft = $false
            reason = "Requested via API call"   
            manualEnvironments = $null       
        }

        if ($PrimaryArtifactBranchName) {

            Write-Verbose -Message "Getting release definition for $ReleaseDefinitionId"
            $GetReleaseDefinitionParams = @{
                Instance = $Instance
                PatToken = $PatToken
                ProjectName = $ProjectName  
                DefinitionId = $ReleaseDefinitionId
            }

            $ReleaseDefinition = Get-ReleaseDefinition @GetReleaseDefinitionParams
            Write-Verbose -Message "Primary artifact alias is $($ReleaseDefinition.PrimaryArtifact.Alias)"

            Write-Verbose -Message "Getting latest build for branch $PrimaryArtefactBranchName"
            $GetBuildParams = @{
                Instance = $Instance
                PatToken = $PatToken
                ProjectId = $ProjectName  
                BranchName = $PrimaryArtifactBranchName
                BuildDefinitionId = $ReleaseDefinition.PrimaryArtifact.BuildDefinitionId
            }

            $LatestBuild = Get-Build @GetBuildParams | Select-Object -First 1

            Write-Verbose -Message "Setting primary artefact for release to BuildNumber: $($LatestBuild.BuildNumber) \ BuildId: $($LatestBuild.BuildId)"

            $Body["artifacts"] = @(
                @{
                    alias = $ReleaseDefinition.PrimaryArtifact.Alias
                    instanceReference = @{
                        id = $LatestBuild.BuildId
                        name = $null
                    }
                }
            )
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