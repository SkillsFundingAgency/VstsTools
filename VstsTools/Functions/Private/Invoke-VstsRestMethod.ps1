function Invoke-VstsRestMethod {
    <#
    .SYNOPSIS
        A generic wrapper to invoke VSTS API calls.
    .DESCRIPTION
        A generic wrapper to invoke VSTS API calls.  Parameters mirror the components of a VSTS API request.  The function is designed to be called from within the exported functions of this module rather 
        than called directly.  It aims to provide a standard method for executing API calls within these functions to reduce code duplication and aid readability.
    .EXAMPLE
        $GetBuildParams = @{
            Instance = $Instance
            PatToken = $PatToken
            Collection = $ProjectId
            Area = "build"
            Resource = "builds"
            ResourceId = $BuildId
            ApiVersion = "4.1"
        }

        $Build = Invoke-VstsRestMethod @GetBuildParams

        Invokes the Builds - Get method of the VSTS API and returns the build specified in BuildId from the project specified in ProjectId
    .OUTPUTS
        PSObject
        Returns a PSObject that represents the strings in a JSON object
    .NOTES
        Api documentation: https://docs.microsoft.com/en-us/rest/api/vsts/
    #>
    [CmdletBinding()]
    param (
        #The Visual Studio Team Services account name
        [Parameter(Mandatory=$true)]
        [string]$Instance,
        
        #A PAT token with the necessary scope to invoke the requested HttpMethod on the specified Resource
        [Parameter(Mandatory=$true)]
        [string]$PatToken,
    
        #The project id, project name or "DefaultCollection" (the default value if not specified)
        [Parameter(Mandatory=$false)]
        [string]$Collection = "DefaultCollection",
    
        #Optional.  Depending on the complexity of the resource the API path may require an Area to be specified as well as a Resource.
        [Parameter(Mandatory=$false)]
        [string]$Area,
    
        #Required.  The resource being targetted.
        [Parameter(Mandatory=$true)]
        [string]$Resource,

        #Optional. Required when API request is targetting a specific resource.
        [Parameter(Mandatory=$false)]
        [string]$ResourceId,
        
        #Optional.  The API allows some resource components to be targetted individually, eg the items in a Git repository.
        [Parameter(Mandatory=$false)]
        [string]$ResourceComponent,

        #Optional. Required when API request is targetting a specific resource component, eg an individual blob in Git repository.
        [Parameter(Mandatory=$false)]
        [string]$ResourceComponentId,

        #Optional. Required when API request is targetting a specific resource subcomponent, eg a diff from a Git repository.
        [Parameter(Mandatory=$false)]
        [string]$ResourceSubComponent,

        #Required.  The version of the API that the request is targetting.
        [Parameter(Mandatory=$true)]
        [string]$ApiVersion,

        #Optional.  Additional URI parameters can be passed as a hash table.  Parameters whose name contains a . should be wrapped in double quotes.
        [Parameter(Mandatory=$false)]
        [hashtable]$AdditionalUriParameters,
    
        #Optional.  Required when targetting resources in the Release area.
        [Parameter(Mandatory=$false)]
        [bool]$ReleaseManager = $false,
    
        #The HTTP method required, eg GET, POST, etc.  The default value is GET.
        [Parameter(Mandatory=$false)]
        [ValidateSet("GET", "HEAD", "PUT", "POST", "PATCH")]
        [string]$HttpMethod = "GET",
    
        #Optional.  Used in conjunction with PUT and POST HTTP Methods.
        [Parameter(Mandatory=$false)]
        [string]$HttpBody
    )
    
    <#

    ##TO DO: decide how to store variables
        Environment Variables
        Vsts Variables
        Fixed variable names if running on VSTS
    Create function(s) to do this
    
    #>

    if($ReleaseManager -eq $true) {

        $Vsrm = ".vsrm"

    }
    
    # Append slash to optional components
    if($TeamProject -ne $null -and $TeamProject -ne "") {

        $TeamProject = "/$TeamProject"

    }
    
    if($Area -ne $null -and $Area -ne "") {

        $Area = "$Area/"

    }

    if($ResourceId -ne $null -and $ResourceId -ne "") {
        
        $ResourceId = "/$ResourceId"

    }

    if($ResourceComponent -ne $null -and $ResourceComponent -ne "") {

        $ResourceComponent = "/$ResourceComponent"

    }

    if($ResourceComponentId -ne $null -and $ResourceComponentId -ne "") {

        $ResourceComponentId = "/$ResourceComponentId"

    }

    if($ResourceSubComponent -ne $null -and $ResourceSubComponent -ne "") {

        $ResourceSubComponent = "/$ResourceSubComponent"

    }

    if($AdditionalUriParameters -ne $null -and $AdditionalUriParameters -ne "") {

        $AdditionalUriParameters.Keys | ForEach-Object { $UriParams += "&$_=$($AdditionalUriParameters.Item($_))"}

    }
    
    $Uri = "https://$Instance$Vsrm.visualstudio.com/$Collection$TeamProject/_apis/$($Area)$($Resource)$($ResourceId)$($ResourceComponent)$($ResourceSubComponent)$($ResourceComponentId)?api-version=$($ApiVersion)$($UriParams)"
    Write-Verbose -Message "Invoking URI: $Uri"
    if($HttpBody -eq $null -or $HttpBody -eq "") {

        $Result = Invoke-RestMethod -Method $HttpMethod -Uri $Uri -Headers @{Authorization = 'Basic' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PatToken)"))}

    }
    else {

        ##TO DO: request with HttpBody

    }
    
    ##TO DO: investigate returning useful error messages

    $Result
}