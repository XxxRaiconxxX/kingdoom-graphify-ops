param(
  [Parameter(Mandatory = $true)]
  [string]$RepoPath,

  [Parameter(Mandatory = $true)]
  [ValidateSet('bot', 'sync', 'fichas', 'library')]
  [string]$Profile,

  [switch]$Activate,
  [switch]$LocalizeGraphifyOut
)

$ErrorActionPreference = 'Stop'

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$opsRoot = Split-Path -Parent $scriptRoot
$templateRoot = Join-Path $opsRoot 'templates'
$resolvedRepo = (Resolve-Path $RepoPath).Path

function Ensure-Directory([string]$Path) {
  if (-not (Test-Path $Path)) {
    New-Item -ItemType Directory -Force -Path $Path | Out-Null
  }
}

function Write-Utf8NoBom([string]$Path, [string]$Content) {
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

function Ensure-GitIgnoreEntry([string]$GitIgnorePath) {
  $snippet = @(
    '# Graphify stays at repo root, but its outputs and Codex hooks are local machine state.',
    '.codex/',
    'graphify-out/'
  )

  $content = if (Test-Path $GitIgnorePath) { Get-Content -Raw $GitIgnorePath } else { '' }
  $normalized = $content -replace "`r`n", "`n"
  foreach ($line in $snippet) {
    if ($normalized -notmatch "(?m)^$([regex]::Escape($line))$") {
      if ($normalized.Length -gt 0 -and -not $normalized.EndsWith("`n")) {
        $normalized += "`n"
      }
      $normalized += "$line`n"
    }
  }
  Write-Utf8NoBom $GitIgnorePath $normalized
}

function Set-AgentsSection([string]$AgentsPath, [string]$SectionPath) {
  $section = (Get-Content -Raw $SectionPath).Trim()
  $content = if (Test-Path $AgentsPath) { Get-Content -Raw $AgentsPath } else { '' }
  $normalized = $content -replace "`r`n", "`n"

  if ($normalized -match '(?s)## graphify.*$') {
    $normalized = [regex]::Replace($normalized, '(?s)## graphify.*$', "$section`n")
  } elseif ($normalized.Trim().Length -gt 0) {
    $normalized = $normalized.TrimEnd() + "`n`n" + $section + "`n"
  } else {
    $normalized = $section + "`n"
  }

  Write-Utf8NoBom $AgentsPath $normalized
}

function Update-PackageScripts([string]$PackagePath) {
  if (-not (Test-Path $PackagePath)) {
    return
  }

  $script = @'
const fs = require("fs");
const path = process.argv[2];
const pkg = JSON.parse(fs.readFileSync(path, "utf8"));
pkg.scripts = pkg.scripts || {};
const entries = {
  "graphify:setup": "node scripts/graphify-manager.mjs setup",
  "graphify:doctor": "node scripts/graphify-manager.mjs doctor",
  "graphify:update": "node scripts/graphify-manager.mjs update",
  "graphify:rebuild": "node scripts/graphify-manager.mjs rebuild",
  "graphify:watch": "graphify watch ."
};
for (const [key, value] of Object.entries(entries)) {
  pkg.scripts[key] = value;
}
fs.writeFileSync(path, JSON.stringify(pkg, null, 2) + "\n");
'@

  $script | node - $PackagePath
}

function Remove-TrackedLocalState([string]$RepoRoot, [string[]]$Paths) {
  Push-Location $RepoRoot
  try {
    foreach ($path in $Paths) {
      $tracked = git ls-files $path
      if ($tracked) {
        git rm -r --cached --ignore-unmatch $path | Out-Null
      }
    }
  } finally {
    Pop-Location
  }
}

Ensure-Directory (Join-Path $resolvedRepo '.agents\rules')
Ensure-Directory (Join-Path $resolvedRepo '.agents\workflows')
Ensure-Directory (Join-Path $resolvedRepo '.codex\skills')
Ensure-Directory (Join-Path $resolvedRepo 'docs\graphify')
Ensure-Directory (Join-Path $resolvedRepo 'scripts')

Copy-Item (Join-Path $templateRoot 'scripts\graphify-manager.mjs') (Join-Path $resolvedRepo 'scripts\graphify-manager.mjs') -Force
Copy-Item (Join-Path $templateRoot 'docs\graphify\OPERATIONS.md') (Join-Path $resolvedRepo 'docs\graphify\OPERATIONS.md') -Force
Copy-Item (Join-Path $templateRoot 'agents\antigravity\rules\graphify.md') (Join-Path $resolvedRepo '.agents\rules\graphify.md') -Force
Copy-Item (Join-Path $templateRoot 'agents\antigravity\workflows\graphify.md') (Join-Path $resolvedRepo '.agents\workflows\graphify.md') -Force
$codexSkillPath = Join-Path $resolvedRepo '.codex\skills\graphify'
if (Test-Path $codexSkillPath) {
  Remove-Item -Recurse -Force $codexSkillPath
}
Copy-Item (Join-Path $templateRoot '.codex\skills\graphify') (Join-Path $resolvedRepo '.codex\skills') -Recurse -Force

Set-AgentsSection (Join-Path $resolvedRepo 'AGENTS.md') (Join-Path $templateRoot "agents\codex\$Profile.md")
Ensure-GitIgnoreEntry (Join-Path $resolvedRepo '.gitignore')
Update-PackageScripts (Join-Path $resolvedRepo 'package.json')
Remove-TrackedLocalState $resolvedRepo @('.codex/hooks.json')

if ($LocalizeGraphifyOut) {
  Remove-TrackedLocalState $resolvedRepo @('graphify-out')
}

if ($Activate) {
  Push-Location $resolvedRepo
  try {
    npm run graphify:setup
  } finally {
    Pop-Location
  }
}
