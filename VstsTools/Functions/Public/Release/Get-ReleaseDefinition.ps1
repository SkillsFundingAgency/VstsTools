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
        [Parameter(Mandatory=$false, ParameterSetName="Id")]
        [Parameter(Mandatory=$false, ParameterSetName="Name")]
        [Parameter(Mandatory=$false, ParameterSetName="Path")]
        [string]$ProjectId,

        #Parameter Description
        [Parameter(Mandatory=$true, ParameterSetName="ProjectName")]
        [Parameter(Mandatory=$false, ParameterSetName="Id")]
        [Parameter(Mandatory=$false, ParameterSetName="Name")]
        [Parameter(Mandatory=$false, ParameterSetName="Path")]
        [string]$ProjectName,

        #Parameter Description
        [Parameter(Mandatory=$true, ParameterSetName="Id")]
        [int]$DefinitionId,

        #Parameter Description
        [Parameter(Mandatory=$true, ParameterSetName="Name")]
        [string]$DefinitionName,

        #The path within Azure DevOps Pipelines that the release(s) are stored within
        [Parameter(Mandatory=$true, ParameterSetName="Path")]
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
            ApiVersion = "5.0"
            ReleaseManager = $true
            AdditionalUriParameters = @{
                '$expand' = "artifacts"
            }
        }

        if ($PSCmdlet.ParameterSetName -eq "Name") {

            $ListDefinitionsParams["AdditionalUriParameters"] = @{
                searchText = $DefinitionName
                '$expand' = "artifacts"
            }

        }
        elseif ($PSCmdlet.ParameterSetName -eq "Id") {

            $ListDefinitionsParams["ResourceId"] = $DefinitionId

        }

        $ListDefinitionsJson = Invoke-VstsRestMethod @ListDefinitionsParams

        if ($PSCmdlet.ParameterSetName -eq "Path") {

            $MatchingPaths = $ListDefinitionsJson.value | Where-Object {$_.path -eq $DefinitionPath}
            Write-Verbose -Message "Found $($MatchingPaths.Count) releases with matching paths"
            if ($MatchingPaths) {

                $ListDefinitionsJson.value = $MatchingPaths

            }
            else {

                throw "No definition paths match DefinitionPath $DefinitionPath"

            }

        }

        if($ListDefinitionsJson.count -eq 1) {

            $Definition = New-ReleaseDefinitionObject -DefinitionJson $ListDefinitionsJson.value[0]

            , $Definition
        
        }
        elseif($ListDefinitionsJson | Get-Member -Name releaseNameFormat) {

            $Definition = New-ReleaseDefinitionObject -DefinitionJson $ListDefinitionsJson

            , $Definition
        
        }
        elseif ($ListDefinitionsJson.count -gt 1 -and $ListDefinitionsJson.value.GetType().BaseType.ToString() -eq "System.Array") {

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
            $Definition.PrimaryArtifact = New-Object -TypeName PipelineArtifact
            $Definition.PrimaryArtifact.Alias = ($DefinitionJson.artifacts | Where-Object {$_.isPrimary -eq $true}).alias
            $Definition.PrimaryArtifact.BuildDefinitionId = ($DefinitionJson.artifacts | Where-Object {$_.isPrimary -eq $true -and $_.Type -eq "Build"}).definitionReference.definition.id

            $Definition
        
        }
}