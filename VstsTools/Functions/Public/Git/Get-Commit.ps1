function Get-Commit {
<#
    .NOTES
    API Reference: https://docs.microsoft.com/en-us/rest/api/vsts/git/commits/get?view=vsts-rest-5.0
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
        [string]$RepositoryId,

        #Parameter Description
        [Parameter(Mandatory=$true)]
        [string]$CommitId
    )
    
    process {

        $GetCommitParams = @{
            Instance = $Instance
            PatToken = $PatToken
            Collection = $Project.id
            Area = "git"
            Resource = "repositories"
            ResourceId = $RepositoryId
            ResourceComponent = "commits"
            ResourceComponentId = $CommitId
            ApiVersion = "4.1"
        }

        $CommitJson = Invoke-VstsRestMethod @GetCommitParams

        $Commit = New-CommitObject -CommitJson $CommitJson

        $Commit

    }
    
}

function New-CommitObject {
    param(
        $CommitJson
    )

        # Check that the object is not a collection
        if (!($CommitJson | Get-Member -Name count)) {

            $Commit = New-Object -TypeName Commit
  
            $Commit.CommitId = $CommitJson.commitId
            $Commit.Comment = $CommitJson.comment
            $Commit.PushDate = $CommitJson.push.date
            $Commit.TreeId = $CommitJson.treeId
            $Commit.Parents = $CommitJson.parents

            $Commit
        
        }
}