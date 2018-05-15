function Get-ReleaseDiff {
<#
    .SYNOPSIS
    Get the Git diffs between the artifacts associated with two releases.
    .NOTES
    API Reference: 
#>
    [CmdletBinding()]
    param (
        #Parameter Description
        [Parameter(Mandatory=$true)]
        [string]$ProjectName,    

        #Parameter Description    
        [Parameter(Mandatory=$true)]
        [string]$BaseReleaseId,

        #Use $(Release.ReleaseId) if calling from VSTS
        [Parameter(Mandatory=$true)]
        [string]$TargetReleaseId,
    
        #The Visual Studio Team Services account name
        [Parameter(Mandatory=$true)]
        [string]$Instance,
        
        #A PAT token with the necessary scope to invoke the requested HttpMethod on the specified Resource
        [Parameter(Mandatory=$true)]
        [string]$PatToken
    )
    
    process {

        # Get project
        $Project = Get-VstsProject -Instance $Instance -PatToken $PatToken -ProjectName $ProjectName

        $TargetRelease = Get-Release  -Instance $Instance -PatToken $PatToken -ProjectName $ProjectName -ReleaseId $TargetReleaseId
        $BaseRelease = Get-Release  -Instance $Instance -PatToken $PatToken -ProjectName $ProjectName -ReleaseId $BaseReleaseId

        foreach($ArtifactCollection in $TargetRelease.Artifacts) {
    
            if($ArtifactCollection.type -eq "Build") {
    
                $TargetBuild = Get-Build -Instance $Instance -PatToken $PatToken -ProjectId $Project.Id -BuildId $ArtifactCollection.definitionReference.version.id
                $RepositoryId = $TargetBuild.RepositoryId

                $BaseReleaseCommitId = ($BaseRelease.Artifacts | Where-Object {$_.type -eq "Build"}).definitionReference.pullRequestMergeCommitId.id
    
                ##TO DO: implement when API docs updated / functionality works
                <#$GetDiffParams = @{
                    Instance = $Instance
                    PatToken = $PatToken
                    Collection = $Project.id
                    Area = "git"
                    Resource = "repositories"
                    ResourceId = $RepositoryId 
                    ResourceComponent = "diffs"
                    ResourceSubComponent = "commits"
                    ApiVersion = "5.0-preview.1"
                    AdditionalUriParameters = @{
                        "baseVersionDescriptor.baseVersion" = $BaseReleaseCommitId
                        "baseVersionDescriptor.baseVersionType" = "commit"
                        "targetVersionDescriptor.targetVersion" = $TargetRelease.definitionReference.pullRequestMergeCommitId.id
                        "targetVersionDescriptor.targetVersionType" = "commit"
                    }
                }

                Invoke-VstsRestMethod @GetDiffParams#>

                ##TO DO: remove this block when preceeding ##TO DO completed
                $Cmd = "git diff $BaseReleaseCommitId $($ArtifactCollection.definitionReference.pullRequestMergeCommitId.id) --name-only"
                if($Env:MSDEPLOY_HTTP_USER_AGENT -ne $null -and ($Env:MSDEPLOY_HTTP_USER_AGENT).Substring(0, 4) -eq "VSTS") {

                    $DiffArtifactsArray = Invoke-Expression $Cmd
                    $DiffArtifacts = @()
                    foreach ($Artifact in $DiffArtifactsArray) {
                        $DiffArtifact = New-Object -TypeName DiffArtifact
                        $DiffArtifact.Name = $Artifact.Split("/")[$Artifact.Split("/").Length - 1]
                        $DiffArtifact.FullName = $Artifact
                        $DiffArtifacts += $DiffArtifact
                    }

                    $DiffArtifacts

                }
                else {

                    Set-Location C:\Users\nick\Source\Repos\grahamandtonic
                    $DiffArtifactsArray = Invoke-Expression $Cmd
                    $DiffArtifacts = @()
                    foreach ($Artifact in $DiffArtifactsArray) {
                        $DiffArtifact = New-Object -TypeName DiffArtifact
                        $DiffArtifact.Name = $Artifact.Split("/")[$Artifact.Split("/").Length - 1]
                        $DiffArtifact.FullName = $Artifact
                        $DiffArtifacts += $DiffArtifact
                    }
                    
                    Write-Host "Cmdlet only implemented to run on VSTS.  To run locally open a cmd prompt in the local clone of the Git repo and execute:`r`n $Cmd"

                }

    
            }
            elseif ($artifactCollection.type -eq "Git") {
                
            }
            else {

                Write-Verbose "Artifact type: $($artifactCollection.type) not recognised.  Please report an issue at $ModuleGitHubRepo"

            }
        }

        $DiffArtifacts

    }
    
}
