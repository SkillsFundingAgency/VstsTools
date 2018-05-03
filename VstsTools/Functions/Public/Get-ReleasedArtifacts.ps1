function Get-ReleasedArtifacts {
<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    Api references:
        list releases: https://docs.microsoft.com/en-us/rest/api/vsts/release/releases/list
        OR
        list deployments: https://docs.microsoft.com/en-us/rest/api/vsts/release/deployments/list
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
    [switch]$MostRecentRelease,

    #The Visual Studio Team Services account name
    [Parameter(Mandatory=$true)]
    [string]$Instance,
    
    #A PAT token with the necessary scope to invoke the requested HttpMethod on the specified Resource
    [Parameter(Mandatory=$true)]
    [string]$PatToken
)

# Get project id
$GetProjectsParams = @{
    Instance = $Instance
    PatToken = $PatToken
    Resource = "projects"
    ApiVersion = "4.1-preview"
}

$Projects = Invoke-VstsRestMethod @GetProjectsParams
$Project = $Projects.value | where-object {$_.name -eq $ProjectName}

# Get list of releases
$GetReleasesListParams = @{
    Instance = $Instance
    PatToken = $PatToken
    Collection = $Project.id
    Area = "release"
    Resource = "deployments"
    ApiVersion = "4.1-preview.2"
    ReleaseManager = $true
}

$ReleasesList = (Invoke-VstsRestMethod @GetReleasesListParams).value

if($MostRecentRelease.IsPresent) {
    # Filter by status, sort by date, select top 1
    $Release = $ReleasesList | Where-Object {$_.deploymentStatus -eq "succeeded"} | Sort-Object -Property completedOn -Descending | Select-Object -First 1
}
##TO DO: implement other Release selectors / filters
    #Failed release
    #Release number

foreach($artifactCollection in $Release.release.artifacts) {
    ##NOTE: retrieving artifacts using properties of $Release.release.artifacts and https://docs.microsoft.com/en-us/rest/api/vsts/build/artifacts/list didn't return required info (lists of files)
    ##DONE: use $artifactCollection.definitionReference.pullRequestMergeCommitId.id and https://docs.microsoft.com/en-us/rest/api/vsts/git/
        ##test whether get commit _links.tree contains sha1 of root tree then use get tree to retrieve entire tree
        ##May need to refactor this func to return metadata about artifacts rather than a list of files
        ##Then leverage https://docs.microsoft.com/en-us/rest/api/vsts/git/diffs/get to achieve desired result
    
    ##These conditional statements may then no longer be relevant
    if($artifactCollection.type -eq "Build") {
        $GetBuildParams = @{
            Instance = $Instance
            PatToken = $PatToken
            Collection = $Project.id
            Area = "build"
            Resource = "builds"
            ResourceId = $artifactCollection.definitionReference.version.id
            ApiVersion = "4.1"
        }

        $Build = Invoke-VstsRestMethod @GetBuildParams
        
        ##TO DO: using $artifactCollection.definitionReference.definition.id and https://docs.microsoft.com/en-us/rest/api/vsts/build/builds/get#uri-parameters get the build, from there get Repository id / name
        $RepositoryId = $Build.repository.id
        
        $GetCommitParams = @{
            Instance = $Instance
            PatToken = $PatToken
            Collection = $Project.id
            Area = "git"
            Resource = "repositories"
            ResourceId = $RepositoryId ##TO DO: get repo id, this isn't in $artifactCollection
            ResourceComponent = "commits"
            ResourceComponentId = $artifactCollection.definitionReference.pullRequestMergeCommitId.id
            ApiVersion = "4.1"
        }

        $Commit = Invoke-VstsRestMethod @GetCommitParams

        # https://docs.microsoft.com/en-us/rest/api/vsts/git/items/list
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
        $Artifact.ReleaseDefinitionName = $Release.releaseDefinition.name
        $Artifact.ReleaseId = $Release.release.id
        $Artifact.ReleaseName = $Release.release.name
        $Artifact.BuildNumber = $Build.buildNumber
        $Artifact.BuildName = $Build.definition.name
        $Artifact.RepositoryId = $Build.repository.id
        $Artifact.RepositoryName = $Build.repository.name
        $Artifacts += $Artifact
    }
}
 
$Artifacts
}