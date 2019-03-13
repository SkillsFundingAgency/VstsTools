##RUN WITH F5 NOT FROM PS prompt
$VerbosePreference = "SilentlyContinue"
#$VerbosePreference = "Continue"
$Classes = Get-ChildItem -Path $PSScriptRoot"\..\VstsTools\Classes\*.ps1"
Write-Host "Importing $($Classes.Count) classes"

foreach($Class in $Classes) {

    try {
        Write-Verbose $Class.FullName
        . $Class.FullName

    }
    catch {

        Write-Error "Failed to import function $($Class.FullName)"

    }

}

$Private = Get-ChildItem -Path $PSScriptRoot"\..\VstsTools\Functions\Private\*.ps1"
Write-Host "Importing $($Private.Count) private functions"

foreach($Function in $Private) {

    try {
        
        Write-Verbose $Function.FullName
        . $Function.FullName

    }
    catch {

        Write-Error "Failed to import function $($Function.FullName)"

    }

}

$Public = Get-ChildItem -Path $PSScriptRoot"\..\VstsTools\Functions\Public\*.ps1" -Recurse
Write-Host "Importing $($Public.Count) public functions"

foreach($Function in $Public) {

    try {
        
        Write-Verbose $Function.FullName
        . $Function.FullName

    }
    catch {

        Write-Error "Failed to import function $($Function.FullName)"

    }

}
