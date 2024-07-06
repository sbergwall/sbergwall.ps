Function New-DokuWikiHeader {
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