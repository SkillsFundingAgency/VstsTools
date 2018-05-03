function Invoke-VstsRestMethod {
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
    
        #Parameter Description
        [Parameter(Mandatory=$false)]
        [string]$Collection = "DefaultCollection",
    
        #Parameter Description
        [Parameter(Mandatory=$false)]
        [string]$TeamProject,
  
        #Parameter Description
        [Parameter(Mandatory=$false)]
        [string]$Area,
    
        #Parameter Description
        [Parameter(Mandatory=$true)]
        [string]$Resource,

        ##TO DO: research and describe additional URI components ($ResourceId, $ResourceComponent, $ResourceComponentId), describe in Parameter Description

        #Parameter Description
        [Parameter(Mandatory=$false)]
        [string]$ResourceId,
        
        #Parameter Description
        [Parameter(Mandatory=$false)]
        [string]$ResourceComponent,

        #Parameter Description
        [Parameter(Mandatory=$false)]
        [string]$ResourceComponentId,

        #Parameter Description
        [Parameter(Mandatory=$true)]
        [string]$ApiVersion,

        #Parameter Description
        [Parameter(Mandatory=$false)]
        [hashtable]$AdditionalUriParameters,
    
        #Parameter Description
        [Parameter(Mandatory=$false)]
        [bool]$ReleaseManager = $false,
    
        #Parameter Description
        [Parameter(Mandatory=$false)]
        [ValidateSet("GET", "HEAD", "PUT", "POST", "PATCH")]
        [string]$HttpMethod = "GET",
    
        #Parameter Description
        [Parameter(Mandatory=$false)]
        [string]$HttpBody
    )
    
    <#
    ##TO DO: decide how to store variables
        Environment Variables
        Vsts Variables
    Create function(s) to do this
    
    #>
    if($ReleaseManager -eq $true) {
        $Vsrm = ".vsrm"
    }
    
    # Append / to optional components
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

    if($AdditionalUriParameters -ne $null -and $AdditionalUriParameters -ne "") {
        $AdditionalUriParameters.Keys | ForEach-Object { $UriParams += "&$_=$($AdditionalUriParameters.Item($_))"}
    }
    
    
    $Uri = "https://$Instance$Vsrm.visualstudio.com/$Collection$TeamProject/_apis/$($Area)$($Resource)$($ResourceId)$($ResourceComponent)$($ResourceComponentId)?api-version=$($ApiVersion)$($UriParams)"
    Write-Verbose -Message "Invoking URI: $Uri"
    if($HttpBody -eq $null -or $HttpBody -eq "") {
        $result = Invoke-RestMethod -Method $HttpMethod -Uri $Uri -Headers @{Authorization = 'Basic' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PatToken)"))}
    }
    else {
        ##TO DO: request with HttpBody
    }
    
    ##TO DO: return error messages

    $result
}