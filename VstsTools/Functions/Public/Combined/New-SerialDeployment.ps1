function New-SerialDeployment {
    <#
    .SYNOPSIS
    Creates the next release in a series and triggers a deployment from a collection of releases.

    .DESCRIPTION
    Creates the next release in a series and triggers a deployment from a collection of releases.  
    The collection of releases can be supplied either as an Azure DevOps folder or an array of release definition names.

    .EXAMPLE
    New-SerialDeployment ##TO DO

    .NOTES
    Requires a PAT token with the following permissions: Build (Read); Release (Read, write, & execute)
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
        [string]$PatToken,

        #(Optional) The name of the branch in the primary artefact that will be released.  The branch name, for git repos must be in the full reference, eg refs/heads/master rather than master.  If not specified then the default version for the primary artefact will be used.
        [Parameter(Mandatory=$false)]    
        [string]$PrimaryArtefactBranchName
    )

    if ($PSCmdlet.ParameterSetName -eq "Names") {

        ##TO DO: get each release defintion by name and add to a collection
        throw "Not implemented - serial release with array of definition names"

    }
    elseif ($PSCmdlet.ParameterSetName -eq "Path") {
        
        if ($ReleaseFolderPath -eq "\") {

            throw "Terminating serial deployment - triggering a serial deployment with a ReleaseFolderPath of '\' will release everything in your project!"

        }

        $ReleaseDefinitions = Get-ReleaseDefinition -DefinitionPath $ReleaseFolderPath -Instance $Instance -PatToken $PatToken -ProjectName $ProjectName | Sort-Object -Property Name
        Write-Verbose -Message "Got $($ReleaseDefinitions.Count) releases: $(($ReleaseDefinitions | Select-Object -Property Name).Name -Join ", ")"
        $TriggerNextRelease = $false
        foreach ($Definition in $ReleaseDefinitions) {

            if ($Definition.Name -eq $ThisRelease) {

                $TriggerNextRelease = $true
                Write-Verbose -Message "Found release definition name matching $ThisRelease, skipping ahead to next release."

                continue

            } 

            if ($TriggerNextRelease) {

                Write-Verbose -Message "Creating release with definition: $($Definition.Name)"
                if ($PrimaryArtefactBranchName) {

                    try {

                        $TriggeredRelease = New-Release -ReleaseDefinitionId $Definition.Id -PrimaryArtifactBranchName $PrimaryArtefactBranchName -ProjectName $ProjectName -Instance $Instance -PatToken $PatToken

                    }
                    catch {

                        Write-Verbose -Message "Failed to create release for $($Definition.Name), skipping ahead to next release definition"
                        continue

                    }


                }
                else {

                    $TriggeredRelease = New-Release -ReleaseDefinitionId $Definition.Id -ProjectName $ProjectName -Instance $Instance -PatToken $PatToken

                }

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