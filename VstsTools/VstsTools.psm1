$Classes = Get-ChildItem -Path "$($PSScriptRoot)\Classes\*.ps1" -Verbose:$VerbosePreference

foreach($Class in $Classes) {

    try {

        . $Class.FullName

    }
    catch {

        Write-Error "Failed to import function $($Class.FullName)"

    }

}

$Private = Get-ChildItem -Path "$($PSScriptRoot)\Functions\Private\*.ps1" -Verbose:$VerbosePreference

foreach($Function in $Private) {

    try {

        . $Function.FullName

    }
    catch {

        Write-Error "Failed to import function $($Function.FullName)"

    }

}

$Public = Get-ChildItem -Path "$($PSScriptRoot)\Functions\Public\*.ps1" -Verbose:$VerbosePreference

foreach($Function in $Public) {

    try {

        . $Function.FullName

    }
    catch {

        Write-Error "Failed to import function $($Function.FullName)"

    }

}

Export-ModuleMember -Function $($Public | Select-Object -ExpandProperty BaseName) -Verbose:$VerbosePreference