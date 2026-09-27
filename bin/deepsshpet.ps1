$ErrorActionPreference = 'Stop'

$toolchainRoot = if ($env:DEEPSSHPET_TOOLCHAIN_DIR) { $env:DEEPSSHPET_TOOLCHAIN_DIR } else { Join-Path $env:LOCALAPPDATA 'DeepSSPet\toolchain' }
$env:PATH = "$(Join-Path $toolchainRoot 'pnpm');$(Join-Path $toolchainRoot 'node-current');$env:PATH"
$configFile = if ($env:DEEPSSHPET_CONFIG) { $env:DEEPSSHPET_CONFIG } else { Join-Path $env:APPDATA 'DeepSSPet\harness-path' }
$serviceUrl = if ($env:DEEPSEEK_HARNESS_URL) { $env:DEEPSEEK_HARNESS_URL } else { 'http://127.0.0.1:3080' }
$petUrl = 'http://127.0.0.1:3081'
$petApp = if ($env:DESKPET_CROSS_APP_DIR) { $env:DESKPET_CROSS_APP_DIR } else { Join-Path $env:LOCALAPPDATA 'DeepSSPet\app' }
$dshHome = if ($env:DSH_HOME) { $env:DSH_HOME } else { Join-Path $env:USERPROFILE '.dsh' }
$credentialsFile = Join-Path $dshHome '.credentials.yaml'

function Test-Url([string]$Url) {
  try { Invoke-WebRequest -Uri $Url -Method Get -TimeoutSec 1 -UseBasicParsing | Out-Null; return $true }
  catch { return $_.Exception.Response -ne $null }
}

function Test-Harness([string]$Path) {
  return $Path -and (Test-Path (Join-Path $Path 'package.json')) -and (Test-Path (Join-Path $Path 'apps\web\index.html'))
}

function Find-Harness {
  $saved = if (Test-Path $configFile) { (Get-Content $configFile -TotalCount 1).Trim() } else { '' }
  $candidates = @($env:DEEPSEEK_HARNESS_HOME, $saved, (Join-Path $env:USERPROFILE 'deepseek-harness'), (Join-Path $env:USERPROFILE 'Documents\deepseek-harness'), (Join-Path $env:USERPROFILE 'Desktop\deepseek-harness'))
  foreach ($candidate in $candidates) { if (Test-Harness $candidate) { return $candidate } }
  return $null
}

function Stop-Harness {
  if (-not (Test-Url $serviceUrl)) {
    Write-Host 'DeepSeek Harness is not running.'
    return
  }

  $uri = [Uri]$serviceUrl
  if ($uri.Host -notin '127.0.0.1', 'localhost', '::1') {
    throw "Refusing to stop a non-local Harness URL: $serviceUrl"
  }
  $connections = @(Get-NetTCPConnection -State Listen -LocalPort $uri.Port -ErrorAction SilentlyContinue)
  $processIds = @($connections | Select-Object -ExpandProperty OwningProcess -Unique)
  if ($processIds.Count -eq 0) { throw "Could not find the local DeepSeek Harness process on port $($uri.Port)." }
  $processIds | ForEach-Object { Stop-Process -Id $_ -Force }
  Write-Host 'DeepSeek Harness stopped.'
}

function Stop-Pet {
  if (-not (Test-Url "$petUrl/state")) {
    Write-Host 'DeskPet is not running.'
    return
  }
  # The app may close its HTTP server before PowerShell receives the response.
  try { Invoke-WebRequest -Uri "$petUrl/quit" -Method Post -ContentType 'application/json' -Body '{}' -TimeoutSec 2 -UseBasicParsing | Out-Null } catch {}
  Write-Host 'DeskPet stopped.'
}

if ($args.Count -gt 0) {
  switch ($args[0]) {
    'stop' {
      if ($args.Count -ne 1) { throw 'Usage: deepsshpet stop' }
      try { Stop-Harness } finally { Stop-Pet }
      exit 0
    }
    { $_ -in '-h', '--help' } {
      Write-Host "Usage:`n  deepsshpet       Start DeskPet and DeepSeek Harness`n  deepsshpet stop  Stop DeepSeek Harness and DeskPet"
      exit 0
    }
    default { throw "Unknown command: $($args[0]). Usage: deepsshpet [stop]" }
  }
}

if (-not (Test-Url "$petUrl/state")) {
  $electron = Join-Path $petApp 'node_modules\.bin\electron.cmd'
  if (Test-Path $electron) { Start-Process -FilePath $electron -ArgumentList @($petApp) -WindowStyle Hidden }
}

if (Test-Url $serviceUrl) {
  try { Invoke-WebRequest -Uri "$petUrl/focus" -Method Post -ContentType 'application/json' -Body '{}' -TimeoutSec 2 -UseBasicParsing | Out-Null }
  catch { Start-Process $serviceUrl }
  Write-Host "DeepSeek Harness is already running: $serviceUrl"
  exit 0
}

$harnessRoot = Find-Harness
if (-not (Test-Harness $harnessRoot)) { throw 'Could not locate DeepSeek Harness. Re-run install.ps1.' }

$hasKey = [bool]$env:DEEPSEEK_API_KEY
if (-not $hasKey -and (Test-Path $credentialsFile)) { $hasKey = Select-String -Path $credentialsFile -Pattern 'DEEPSEEK_API_KEY' -Quiet }
if (-not $hasKey) {
  $secure = Read-Host 'DeepSeek API Key is required for first launch' -AsSecureString
  $pointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
  try { $apiKey = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($pointer) } finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($pointer) }
  if (-not $apiKey) { throw 'DeepSeek API Key cannot be empty.' }
  New-Item -ItemType Directory -Force -Path $dshHome | Out-Null
  $env:CREDENTIALS_FILE = $credentialsFile
  $env:DEEPSSHPET_API_KEY_INPUT = $apiKey
  Push-Location $harnessRoot
  try {
    node -e "const fs=require('node:fs'),{createRequire}=require('node:module'),{Document,parseDocument}=createRequire(process.cwd()+'/packages/credentials/credentials-local/package.json')('yaml');const f=process.env.CREDENTIALS_FILE;const d=fs.existsSync(f)?parseDocument(fs.readFileSync(f,'utf8')):new Document({version:1,refs:{},records:{}});d.setIn(['refs','DEEPSEEK_API_KEY'],process.env.DEEPSSHPET_API_KEY_INPUT);fs.writeFileSync(f,String(d));"
  } finally { Pop-Location; Remove-Item Env:DEEPSSHPET_API_KEY_INPUT -ErrorAction SilentlyContinue }
}

New-Item -ItemType Directory -Force -Path (Split-Path $configFile) | Out-Null
Set-Content -Path $configFile -Value $harnessRoot
Set-Location $harnessRoot
& pnpm.cmd dsh web
