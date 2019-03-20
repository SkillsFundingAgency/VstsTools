class Release {

    [int]$ReleaseId
    [string]$ReleaseName
    [DateTime]$CreatedOn
    [int]$ReleaseDefintionId
    [string]$ReleaseDefintionName
    [object[]]$Artifacts
    [Environment[]]$Environments
    
}