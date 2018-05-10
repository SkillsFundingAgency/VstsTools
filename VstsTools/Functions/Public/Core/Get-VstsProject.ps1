function Get-VstsProject {
<#
    .NOTES
    API Reference: undocumented
#>
    [CmdletBinding()]
    param (
        #The Visual Studio Team Services account name
        [Parameter(Mandatory=$true)]
        [string]$Instance,
        
        #A PAT token with the necessary scope to invoke the requested HttpMethod on the specified Resource
        [Parameter(Mandatory=$true)]
        [string]$PatToken,
        
        #Specifies the name of the project to return
        [Parameter(Mandatory=$true)]
        [string]$ProjectName
    )
    
    process {

        $GetProjectsParams = @{
            Instance = $Instance
            PatToken = $PatToken
            Resource = "projects"
            ApiVersion = "4.1-preview"
        }
        
        $ProjectsJson = Invoke-VstsRestMethod @GetProjectsParams

        if ($ProjectName -eq $null -and $ProjectName -eq "") {

            $Projects = @()
            foreach ($Project in $ProjectsJson.value) {
                $Project = New-VstsProjectObject -ProjectJson ($Project)
                $Projects += $Project
            }
            $Projects

        }
        else {

            $Project = New-VstsProjectObject -ProjectJson ($ProjectsJson.value | Where-Object {$_.name -eq $ProjectName})
            $Project

        }

    }

}

function New-VstsProjectObject {
    param(
        $ProjectJson
    )

    # Check that the object is not a collection
    if (!($ProjectJson | Get-Member -Name count)) {
        
        $Project = New-Object -TypeName VstsProject

        $Project.Id = $ProjectJson.id
        $Project.Name = $ProjectJson.Name
        $Project.Description = $ProjectJson.description
        $Project.Url = $ProjectJson.url
        $Project.State = $ProjectJson.state
        $Project.Revision = $ProjectJson.revision
        $Project.Visibility = $ProjectJson.visibility
    
        $Project

    }

}