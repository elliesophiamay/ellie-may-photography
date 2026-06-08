#!/bin/bash

# ─────────────────────────────────────────────────────────────
#  Ellie May Photography — Deploy Script
#  Usage:  ./deploy.sh "Your commit message"
#  Requires: gh (GitHub CLI) + vercel (Vercel CLI) via Homebrew
# ─────────────────────────────────────────────────────────────

set -e  # exit on any error

# ── Ensure Homebrew bin is on PATH (required for node/vercel) ─
export PATH="/opt/homebrew/bin:$PATH"

# ── Tool paths ────────────────────────────────────────────────
GH="gh"
VERCEL="vercel"
GIT="git"

# ── Colour helpers ────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${CYAN}▶  $1${NC}"; }
success() { echo -e "${GREEN}✓  $1${NC}"; }
warn()    { echo -e "${YELLOW}⚠  $1${NC}"; }
error()   { echo -e "${RED}✗  $1${NC}"; exit 1; }

# ── Validate tools ────────────────────────────────────────────
command -v "$GH"     >/dev/null 2>&1 || error "GitHub CLI not found. Run: brew install gh"
command -v "$VERCEL" >/dev/null 2>&1 || error "Vercel CLI not found. Run: brew install vercel-cli"

# ── Commit message ────────────────────────────────────────────
COMMIT_MSG="${1:-"Update site"}"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🚀  Ellie May Photography — Deploying…"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── Step 1: Stage all changes ─────────────────────────────────
info "Staging all changes…"
$GIT add -A

# Check if there's anything to commit
if $GIT diff --cached --quiet; then
  warn "Nothing new to commit — working tree already clean."
else
  info "Committing: \"$COMMIT_MSG\""
  $GIT commit -m "$COMMIT_MSG"
  success "Committed!"

  # ── Step 2: Push to GitHub ────────────────────────────────
  info "Pushing to GitHub (origin/main)…"
  $GH repo sync 2>/dev/null || $GIT push origin main
  success "Pushed to GitHub → https://github.com/elliesophiamay/ellie-may-photography"
fi

echo ""

# ── Step 3: Deploy to Vercel (production) ─────────────────────
info "Deploying to Vercel (production)…"
DEPLOY_OUTPUT=$($VERCEL --prod --yes 2>&1)
DEPLOY_URL=$(echo "$DEPLOY_OUTPUT" | grep -E "^https://" | tail -1)

echo ""
success "Deployed! 🎉"
echo ""
echo "  🌐  Live URL : ${DEPLOY_URL:-"https://vercel.com/elliesophiamay"}"
echo "  📁  GitHub   : https://github.com/elliesophiamay/ellie-may-photography"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
