Function New-DokuWikiHeader {
    <#
    .SYNOPSIS
        Creates DokuWiki formatted headers.

    .DESCRIPTION
        The New-DokuWikiHeader function creates properly formatted headers for DokuWiki syntax.
        It supports header levels H1 through H5 and ensures correct equals sign placement.

    .PARAMETER HeadlineSize
        Specifies the header level (H1-H5).
        H1 is the largest header size, H5 is the smallest.
        Valid values: 'H1', 'H2', 'H3', 'H4', 'H5'

    .PARAMETER HeadlineText
        The text content of the header.

    .EXAMPLE
        New-DokuWikiHeader -HeadlineSize 'H1' -HeadlineText 'Main Title'
        Returns: ====== Main Title ======

    .EXAMPLE
        New-DokuWikiHeader -HeadlineSize 'H3' -HeadlineText 'Subsection'
        Returns: ==== Subsection ====

    .NOTES
        Author: Simon Bergwall
        Version: 1.0

    .LINK
        https://github.com/sbergwall/sbergwall.ps

    .OUTPUTS
        [String] DokuWiki formatted header
    #>

    [CmdletBinding()]
    param (
        [ValidateSet('H1', 'H2', 'H3', 'H4', 'H5')]
        [string]$HeadlineSize,
        [string]$HeadlineText
    )

    switch ($HeadlineSize) {
        'H1' { "====== $HeadlineText ======" }
        'H2' { "===== $HeadlineText =====" }
        'H3' { "==== $HeadlineText ====" }
        'H4' { "=== $HeadlineText ===" }
        'H5' { "== $HeadlineText ==" }
    }
}