function Get-ReleasedArtifacts {
<#
    .SYNOPSIS
        Short description
    .DESCRIPTION
        Long description
    .EXAMPLE
        PS C:\> Get-ReleasedArtifacts -Project myproject -ReleaseEnvironment PROD -Instance myvstsinstance -PatToken "xxxxxxxxxxx" -MostRecentRelease -Verbose
        Retrieves the artifacts used in the most recent successful deployment to the PROD environment 
    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .NOTES
        Api reference: https://docs.microsoft.com/en-us/rest/api/vsts/git/repositories/list?view=vsts-rest-5.0
            list releases: https://docs.microsoft.com/en-us/rest/api/vsts/release/releases/list
            OR
            list deployments: 
            get release definition: https://docs.microsoft.com/en-us/rest/api/vsts/release/releases/get%20release%20definition%20summary
#>
    [CmdletBinding()]
    param(
        #Parameter Description
        [Parameter(Mandatory=$true)]
        [string]$ProjectName,

        #Parameter Description
        [Parameter(Mandatory=$true)]
        [string]$ReleaseEnvironment,

        ##TO DO: implement ParameterSet to make a selector \ filter mandatory

        #Parameter Description
        [Parameter(Mandatory=$false)]
        [switch]$MostRecentDeployment,

        #The Visual Studio Team Services account name
        [Parameter(Mandatory=$true)]
        [string]$Instance,
        
        #A PAT token with the necessary scope to invoke the requested HttpMethod on the specified Resource
        [Parameter(Mandatory=$true)]
        [string]$PatToken
    )

    # Get project
    $Project = Get-VstsProject -Instance $Instance -PatToken $PatToken -ProjectName $ProjectName

    # Get release
    if($MostRecentDeployment.IsPresent) {
        $Deployment = Get-Deployment -Instance $Instance -PatToken $PatToken -ProjectId $Project.Id -ReleaseEnvironment $ReleaseEnvironment -MostRecentDeployment
    }

    foreach($ArtifactCollection in $Deployment.Artifacts) {
        
        if($ArtifactCollection.type -eq "Build") {

            $Build = Get-Build -Instance $Instance -PatToken $PatToken -ProjectId $Project.Id -BuildId $ArtifactCollection.definitionReference.version.id
            $RepositoryId = $Build.RepositoryId
            
            $Commit = Get-Commit -Instance $Instance -PatToken $PatToken -ProjectId $Project.Id -RepositoryId $RepositoryId -CommitId $artifactCollection.definitionReference.pullRequestMergeCommitId.id

            $GetListItemsParams = @{
                Instance = $Instance
                PatToken = $PatToken
                Collection = $Project.id
                Area = "git"
                Resource = "repositories"
                ResourceId = $RepositoryId 
                ResourceComponent = "items"
                ApiVersion = "4.1"
                AdditionalUriParameters = @{
                    recursionLevel = "full"
                    "versionDescriptor.version" = $Commit.commitId
                    "versionDescriptor.versionType" = "commit"
                }
            }

            $Items = Invoke-VstsRestMethod @GetListItemsParams

        }
        elseif ($artifactCollection.type -eq "Git") {
            
        }
        else {
            Write-Verbose "Artifact type: $($artifactCollection.type) not recognised.  Please report an issue at $ModuleGitHubRepo"
        }
    }

    $Artifacts = @()

    foreach ($Item in $Items.value) {

        if($Item.gitObjectType -eq "blob") {

            $Artifact = New-Object -TypeName ReleasedArtifact
            $Artifact.ObjectId = $Item.objectId
            $Artifact.Filename = $Item.path.split("/")[$Item.path.split("/").Count -1]
            $Artifact.Path = $Item.path
            $Artifact.ReleaseDefinitionName = $DeploymentReleaseDefinition
            $Artifact.ReleaseId = $Deployment.Id
            $Artifact.ReleaseName = $Deployment.ReleaseName
            $Artifact.BuildNumber = $Build.buildNumber
            $Artifact.BuildName = $Build.definition.name
            $Artifact.RepositoryId = $Build.repository.id
            $Artifact.RepositoryName = $Build.repository.name
            $Artifacts += $Artifact

        }
        
    }
    
    $Artifacts
}