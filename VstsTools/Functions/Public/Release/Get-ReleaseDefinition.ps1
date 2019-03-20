function Get-ReleaseDefinition {
    [CmdletBinding()]
    param (
        #The Visual Studio Team Services account name
        [Parameter(Mandatory=$true)]
        [string]$Instance,
        
        #A PAT token with the necessary scope to invoke the requested HttpMethod on the specified Resource
        [Parameter(Mandatory=$true)]
        [string]$PatToken,   

        #Parameter Description
        [Parameter(Mandatory=$true, ParameterSetName="ProjectId")]
        [string]$ProjectId,

        #Parameter Description
        [Parameter(Mandatory=$true, ParameterSetName="ProjectName")]
        [string]$ProjectName,

        #Parameter Description
        [Parameter(Mandatory=$false)]
        [string]$DefinitionName,

        #The path within Azure DevOps Pipelines that the release(s) are stored within
        [Parameter(Mandatory=$false)]
        [string]$DefinitionPath
    )
    
    begin {

        if(!$ProjectId) {

            $Project = Get-VstsProject -ProjectName $ProjectName -Instance $Instance -PatToken $PatToken -Verbose:$VerbosePreference
            $ProjectId = $Project.Id

        }

    }

    process {

        $ListDefinitionsParams = @{
            Instance = $Instance
            PatToken = $PatToken
            Collection = $ProjectId
            Area = "release"
            Resource = "definitions"
            ApiVersion = "5.0-preview.3"
            ReleaseManager = $true
        }

        if ($DefinitionName) {

            $ListDefinitionsParams["AdditionalUriParameters"] = @{
                searchText = $DefinitionName
            }

        }

        $ListDefinitionsJson = Invoke-VstsRestMethod @ListDefinitionsParams

        if ($DefinitionPath) {

            $MatchingPaths = $ListDefinitionsJson.value | Where-Object {$_.path -eq $DefinitionPath}
            Write-Verbose -Message "Found $($MatchingPaths.Count) releases with matching paths"
            $ListDefinitionsJson.value = $MatchingPaths

        }

        if($ListDefinitionsJson.count -eq 1) {

            $Definition = New-ReleaseDefinitionObject -DefinitionJson $ListDefinitionsJson.value[0]

            , $Definition
        
        }
        elseif ($ListDefinitionsJson.count -gt 1) {

            $Definitions = @()
            
            foreach ($Definition in $ListDefinitionsJson.value) {

                $Definitions += New-ReleaseDefinitionObject -DefinitionJson $Definition

            }
            
            $Definitions

        }
        else {

            throw "No definition names match DefinitionName $DefinitionName"

        }

    }
    
}

function New-ReleaseDefinitionObject {
    param(
        $DefinitionJson
    )

        # Check that the object is not a collection
        if (!($DefinitionJson | Get-Member -Name count)) {

            $Definition = New-Object -TypeName ReleaseDefinition
    
            $Definition.Id = $DefinitionJson.id
            $Definition.Name = $DefinitionJson.name
            $Definition.Path = $DefinitionJson.path
    
            $Definition
        
        }
}