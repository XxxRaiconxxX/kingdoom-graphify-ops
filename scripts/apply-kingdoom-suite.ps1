$ErrorActionPreference = 'Stop'

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$opsRoot = Split-Path -Parent $scriptRoot
$suiteRoot = Split-Path -Parent $opsRoot
$applyScript = Join-Path $scriptRoot 'apply-to-repo.ps1'

$targets = @(
  @{ Path = (Join-Path $suiteRoot 'kingdoom-bot'); Profile = 'bot'; Localize = $false },
  @{ Path = (Join-Path $suiteRoot 'Kingdoom-sync'); Profile = 'sync'; Localize = $true },
  @{ Path = (Join-Path $suiteRoot 'kingdoom-fichas'); Profile = 'fichas'; Localize = $false }
)

foreach ($target in $targets) {
  if ($target.Localize) {
    & $applyScript -RepoPath $target.Path -Profile $target.Profile -Activate -LocalizeGraphifyOut
  } else {
    & $applyScript -RepoPath $target.Path -Profile $target.Profile -Activate
  }
}
