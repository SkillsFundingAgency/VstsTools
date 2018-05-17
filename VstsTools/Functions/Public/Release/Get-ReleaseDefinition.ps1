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
        [Parameter(Mandatory=$true)]
        [string]$DefinitionName
    )
    
    begin {

        if($ProjectId -eq $null -and $ProjectId -eq "") {

            $Project = Get-VstsProject -ProjectName $ProjectName -Instance $Instance -PatToken $PatToken
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
            AdditionalUriParameters = @{
                searchText = $DefinitionName
            }
        }

        $ListDefinitionsJson = Invoke-VstsRestMethod @ListDefinitionsParams

        if($ListDefinitionsJson.count -eq 1) {

            $Definition = New-ReleaseDefinitionObject -DefinitionJson $ListDefinitionsJson.value[0]

            $Definition
        
        }
        else {

            throw "More than 1 definition matches DefinitionName $DefinitionName"

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
    
            $Definition
        
        }
}