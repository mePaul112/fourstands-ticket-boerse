#!/bin/bash
# ──────────────────────────────────────────────────────────────
#  FourStands Ticket-Börse – GitHub Setup Script
#  Voraussetzung: GitHub CLI (gh) installiert und eingeloggt
#  Installation: https://cli.github.com
# ──────────────────────────────────────────────────────────────

set -e

REPO_NAME="fourstands-ticket-boerse"
DESCRIPTION="FC St. Pauli FourStands Fanclub – Ticket-Börse mit Echtzeit-Sync"

echo ""
echo "☠  FourStands Ticket-Börse – GitHub Setup"
echo "──────────────────────────────────────────"
echo ""

# Prüfen ob gh installiert ist
if ! command -v gh &> /dev/null; then
  echo "❌  GitHub CLI (gh) nicht gefunden."
  echo "    Installieren: https://cli.github.com"
  echo "    macOS: brew install gh"
  echo "    Windows: winget install GitHub.cli"
  exit 1
fi

# Prüfen ob eingeloggt
if ! gh auth status &> /dev/null; then
  echo "🔑  Bitte erst einloggen:"
  gh auth login
fi

echo "✓  GitHub CLI bereit"
echo ""

# Git initialisieren falls nötig
if [ ! -d .git ]; then
  git init
  echo "✓  Git initialisiert"
fi

# Alle Dateien stagen
git add .
git commit -m "🎟️ Initial commit: FourStands Ticket-Börse" 2>/dev/null || echo "  (Keine neuen Commits)"

# GitHub Repo erstellen und pushen
echo ""
echo "📦  Erstelle GitHub Repository '$REPO_NAME'..."
gh repo create "$REPO_NAME" \
  --public \
  --description "$DESCRIPTION" \
  --source=. \
  --remote=origin \
  --push

echo ""
echo "⚙️  Aktiviere GitHub Pages..."
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  "/repos/$(gh api user --jq .login)/$REPO_NAME/pages" \
  -f source='{"branch":"main","path":"/"}' \
  2>/dev/null || true

# GitHub Actions aktivieren (passiert automatisch durch den Workflow)
USERNAME=$(gh api user --jq .login)

echo ""
echo "────────────────────────────────────────────"
echo "✅  Fertig! Nächste Schritte:"
echo ""
echo "1. GitHub Actions Deploy abwarten (~1 Min.):"
echo "   https://github.com/$USERNAME/$REPO_NAME/actions"
echo ""
echo "2. App aufrufen:"
echo "   https://$USERNAME.github.io/$REPO_NAME/"
echo ""
echo "3. Mit Claude Code weiterentwickeln:"
echo "   claude"
echo ""
echo "☠  Hisn Hisn Hisn!"
echo "────────────────────────────────────────────"
