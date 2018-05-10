$Classes = Get-ChildItem -Path "..\VstsTools\Classes\*.ps1" -Verbose

foreach($Class in $Classes) {

    try {

        . $Class.FullName

    }
    catch {

        Write-Error "Failed to import function $($Class.FullName)"

    }

}

$Private = Get-ChildItem -Path "..\VstsTools\Functions\Private\*.ps1" -Verbose

foreach($Function in $Private) {

    try {

        . $Function.FullName

    }
    catch {

        Write-Error "Failed to import function $($Function.FullName)"

    }

}

$Public = Get-ChildItem -Path "..\VstsTools\Functions\Public\*.ps1" -Recurse -Verbose

foreach($Function in $Public) {

    try {

        . $Function.FullName

    }
    catch {

        Write-Error "Failed to import function $($Function.FullName)"

    }

}
