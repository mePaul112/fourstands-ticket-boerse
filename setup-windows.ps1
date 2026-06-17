# ============================================================
#  FourStands Ticket-Boerse - Windows Setup Script
#  Ausfuehren in PowerShell (nicht CMD!)
#  Rechtsklick auf PowerShell -> "Als Administrator ausfuehren"
# ============================================================

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "  Skull  FourStands Ticket-Boerse - GitHub Setup" -ForegroundColor Red
Write-Host "  ================================================" -ForegroundColor DarkRed
Write-Host ""

# ── SCHRITT 1: ZIP entpacken ─────────────────────────────────
$zipPath = "$env:USERPROFILE\Downloads\fourstands-ticket-boerse.zip"
$destPath = "$env:USERPROFILE\fourstands-ticket-boerse"

if (Test-Path $zipPath) {
    Write-Host "[1/5] ZIP entpacken..." -ForegroundColor Yellow
    Expand-Archive -Path $zipPath -DestinationPath $destPath -Force
    Write-Host "  OK: Entpackt nach $destPath" -ForegroundColor Green
} else {
    Write-Host "  FEHLER: ZIP nicht gefunden unter:" -ForegroundColor Red
    Write-Host "  $zipPath" -ForegroundColor Red
    Write-Host "  Bitte ZIP erst in den Downloads-Ordner legen." -ForegroundColor Yellow
    exit 1
}

# In den Projektordner wechseln
$projectPath = "$destPath\fourstands"
Set-Location $projectPath
Write-Host "  Ordner: $projectPath" -ForegroundColor DarkGray

# ── SCHRITT 2: GitHub CLI installieren ───────────────────────
Write-Host ""
Write-Host "[2/5] GitHub CLI pruefen..." -ForegroundColor Yellow

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "  GitHub CLI nicht gefunden - installiere..." -ForegroundColor Yellow
    
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --id GitHub.cli --silent --accept-source-agreements --accept-package-agreements
        # PATH neu laden
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
    } else {
        Write-Host "  FEHLER: winget nicht verfuegbar." -ForegroundColor Red
        Write-Host "  Bitte manuell installieren: https://cli.github.com" -ForegroundColor Yellow
        exit 1
    }
}
Write-Host "  OK: GitHub CLI bereit" -ForegroundColor Green

# ── SCHRITT 3: Git pruefen ───────────────────────────────────
Write-Host ""
Write-Host "[3/5] Git pruefen..." -ForegroundColor Yellow

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "  Git nicht gefunden - installiere..." -ForegroundColor Yellow
    winget install --id Git.Git --silent --accept-source-agreements --accept-package-agreements
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
}
Write-Host "  OK: Git bereit" -ForegroundColor Green

# ── SCHRITT 4: GitHub Login ──────────────────────────────────
Write-Host ""
Write-Host "[4/5] GitHub Login..." -ForegroundColor Yellow

$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  Browser oeffnet sich fuer GitHub Login..." -ForegroundColor Cyan
    gh auth login --web --git-protocol https
} else {
    Write-Host "  OK: Bereits eingeloggt" -ForegroundColor Green
}

# ── SCHRITT 5: Repo erstellen und pushen ─────────────────────
Write-Host ""
Write-Host "[5/5] GitHub Repository erstellen und pushen..." -ForegroundColor Yellow

# Git initialisieren
if (-not (Test-Path ".git")) {
    git init
    git branch -M main
}

git add .
git commit -m "Initial commit: FourStands Ticket-Boerse" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "  (Keine neuen Aenderungen)" -ForegroundColor DarkGray
}

# Repo erstellen
gh repo create fourstands-ticket-boerse `
    --public `
    --description "FC St. Pauli FourStands Fanclub - Ticket-Boerse" `
    --source=. `
    --remote=origin `
    --push

# GitHub Pages aktivieren
Write-Host ""
Write-Host "  GitHub Pages aktivieren..." -ForegroundColor Yellow
$username = (gh api user --jq .login)

gh api `
    --method POST `
    -H "Accept: application/vnd.github+json" `
    "/repos/$username/fourstands-ticket-boerse/pages" `
    -f "source[branch]=main" `
    -f "source[path]=/" 2>$null

if ($LASTEXITCODE -eq 0) {
    Write-Host "  OK: GitHub Pages aktiviert" -ForegroundColor Green
} else {
    Write-Host "  Hinweis: Pages manuell aktivieren unter:" -ForegroundColor Yellow
    Write-Host "  https://github.com/$username/fourstands-ticket-boerse/settings/pages" -ForegroundColor Cyan
}

# ── FERTIG ───────────────────────────────────────────────────
Write-Host ""
Write-Host "  ================================================" -ForegroundColor DarkRed
Write-Host "  FERTIG!" -ForegroundColor Green
Write-Host ""
Write-Host "  App wird in ~1-2 Minuten live sein:" -ForegroundColor White
Write-Host "  https://$username.github.io/fourstands-ticket-boerse/" -ForegroundColor Cyan
Write-Host ""
Write-Host "  GitHub Repository:" -ForegroundColor White
Write-Host "  https://github.com/$username/fourstands-ticket-boerse" -ForegroundColor Cyan
Write-Host ""
Write-Host "  GitHub Actions (Deploy-Status):" -ForegroundColor White
Write-Host "  https://github.com/$username/fourstands-ticket-boerse/actions" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Claude Code starten (im Projektordner):" -ForegroundColor White
Write-Host "  cd $projectPath" -ForegroundColor DarkGray
Write-Host "  claude" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Hisn Hisn Hisn!" -ForegroundColor Red
Write-Host "  ================================================" -ForegroundColor DarkRed
