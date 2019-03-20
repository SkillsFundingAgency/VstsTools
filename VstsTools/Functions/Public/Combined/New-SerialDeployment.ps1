function New-SerialDeployment {
    <#
    .SYNOPSIS
    Creates the next release in a series and triggers a deployment from a collection of releases.
    .DESCRIPTION
    Creates the next release in a series and triggers a deployment from a collection of releases.  
    The collection of releases can be supplied either as an Azure DevOps folder or an array of release definition names.
    .EXAMPLE
    New-SerialDeployment ##TO DO
    #>
    [CmdletBinding()]
    param(
        #The environment name
        [Parameter(Mandatory=$true)]
        [string]$EnvironmentName, 
        
        #The path to a folder of release definitions with Azure DevOps Releases
        [Parameter(Mandatory=$true, ParameterSetName="Path")]
        [string]$ReleaseFolderPath,

        #An array of release names
        [Parameter(Mandatory=$true, ParameterSetName="Names")]
        [string[]]$ReleaseNames,
        
        #The name of the release triggering the serial deployment.  The next release to be triggered will be the release after this one in the collection.
        [Parameter(Mandatory=$true)]
        [string]$ThisRelease,
    
        #Parameter Description
        [Parameter(Mandatory=$true)]
        [string]$ProjectName,

        #The Visual Studio Team Services account name
        [Parameter(Mandatory=$true)]
        [string]$Instance,

        #A PAT token with the necessary scope to invoke the requested HttpMethod on the specified Resource
        [Parameter(Mandatory=$true)]
        [string]$PatToken
    )

    if ($PSCmdlet.ParameterSetName -eq "Names") {

        ##TO DO: get each release defintion by name and add to a collection

    }
    elseif ($PSCmdlet.ParameterSetName -eq "Path") {
        
        $ReleaseDefinitions = Get-ReleaseDefinition -DefinitionPath $ReleaseFolderPath -Instance $Instance -PatToken $PatToken -ProjectName $ProjectName
        Write-Verbose -Message "Got $($ReleaseDefinitions.Count) releases: $(($ReleaseDefinitions | Select-Object -Property Name).Name -Join ", ")"
        $TriggerNextRelease = $false
        foreach ($Definition in $ReleaseDefinitions) {

            if ($Definition.Name -eq $ThisRelease) {

                $TriggerNextRelease = $true
                Write-Verbose -Message "Found release name matching $ThisRelease, skipping ahead to next release."

                continue

            } 

            if ($TriggerNextRelease) {

                Write-Verbose -Message "Creating release with definition: $($Definition.Name)"
                $TriggeredRelease = New-Release -ProjectName $ProjectName -ReleaseDefinitionId $Definition.Id -Instance $Instance -PatToken $PatToken
                $EnvironmentId = ($TriggeredRelease.Environments | Where-Object {$_.Name -eq $EnvironmentName}).ReleaseEnvironmentId
                Write-Verbose -Message "Triggering deployment for environment $EnvironmentId ($EnvironmentName) in release $($TriggeredRelease.ReleaseId) ($($Definition.Name))"
                $TriggeredEnvironment = New-Deployment -EnvironmentId $EnvironmentId -ReleaseId $TriggeredRelease.ReleaseId -ProjectName $ProjectName -Instance $Instance -PatToken $PatToken

                $TriggeredEnvironment

                break

            }

        }

    }
    else {

        throw "Must specify an array of names or a path."

    }
}