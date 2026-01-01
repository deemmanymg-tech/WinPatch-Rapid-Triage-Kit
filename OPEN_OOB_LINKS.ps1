<#
OPEN_OOB_LINKS.ps1 — ReactedHQ helper
Opens Microsoft Update Catalog search pages for the relevant OOB KBs.
Safe: opens browser only; no downloads or installs.
#>

[CmdletBinding()]
param(
  [Parameter()][string[]]$KBs = @("KB5074976","KB5074975","KB5074974","KB5071959")
)

$base = "https://www.catalog.update.microsoft.com/Search.aspx?q="
foreach($kb in $KBs){
  $url = $base + [uri]::EscapeDataString($kb)
  Write-Host "Opening: $url"
  Start-Process $url
}
