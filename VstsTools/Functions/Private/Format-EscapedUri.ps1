
function Format-EscapedUri {
    <#
    .SYNOPSIS
        Prevents older versions of PowerShell from un-percent encoding the query string on a URI.
    .DESCRIPTION
        Prevents older versions of PowerShell from un-percent encoding the query string on a URI.  Use reflection and set a private field on the .Net class to prevent this behaviour.
    .NOTES
        Based on StackOverflow answer: https://stackoverflow.com/a/25599183
    #>
    param(
        # The Uri to fix
        [Uri]$Uri
    )
    $Uri.PathAndQuery | Out-Null
    $m_Flags = [Uri].GetField("m_Flags", $([Reflection.BindingFlags]::Instance -bor [Reflection.BindingFlags]::NonPublic))
    [uint64]$flags = $m_Flags.GetValue($Uri)
    $m_Flags.SetValue($Uri, $($flags -bxor 0x30))

    $Uri
}