#!/bin/bash

# ─────────────────────────────────────────────────────────────
#  Ellie May Photography — Deploy Script
#  Usage:  ./deploy.sh "Your commit message"
#  Always commits + pushes directly to main, then deploys live.
# ─────────────────────────────────────────────────────────────

set -e

# ── Ensure Homebrew bin is on PATH ────────────────────────────
export PATH="/opt/homebrew/bin:$PATH"

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
command -v gh     >/dev/null 2>&1 || error "GitHub CLI not found. Run: brew install gh"
command -v vercel >/dev/null 2>&1 || error "Vercel CLI not found. Run: brew install vercel-cli"

# ── Commit message ────────────────────────────────────────────
COMMIT_MSG="${1:-"Update site"}"

# ── Always ensure we are on main ──────────────────────────────
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
  warn "Not on main (currently on '$CURRENT_BRANCH'). Switching to main…"
  git checkout main
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🚀  Ellie May Photography — Deploying…"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── Step 1: Stage all changes ─────────────────────────────────
info "Staging all changes…"
git add -A

# ── Step 2: Commit (skip if nothing changed) ──────────────────
if git diff --cached --quiet; then
  warn "Nothing new to commit — working tree already clean."
else
  info "Committing: \"$COMMIT_MSG\""
  git commit -m "$COMMIT_MSG"
  success "Committed!"

  # ── Step 3: Push to GitHub main ──────────────────────────────
  info "Pushing to GitHub → main…"
  git push origin main
  success "Pushed → https://github.com/elliesophiamay/ellie-may-photography"
fi

echo ""

# ── Step 4: Deploy to Vercel production ───────────────────────
info "Deploying to Vercel (production)…"
DEPLOY_OUTPUT=$(vercel --prod --yes 2>&1)
DEPLOY_URL=$(echo "$DEPLOY_OUTPUT" | grep -oE "https://ellie-may-photography-[a-z0-9]+-elliesophiamay-coder\.vercel\.app" | head -1)

if [ -z "$DEPLOY_URL" ]; then
  warn "Could not extract deployment URL — skipping alias update."
else
  success "Deployed to: $DEPLOY_URL"

  # ── Step 5: Re-alias custom domains to latest deployment ──────
  info "Updating custom domain aliases…"
  vercel alias set "$DEPLOY_URL" www.elliemayphotos.com >/dev/null 2>&1 \
    && success "www.elliemayphotos.com → latest deployment" \
    || warn "Failed to alias www.elliemayphotos.com"

  vercel alias set "$DEPLOY_URL" elliemayphotos.com >/dev/null 2>&1 \
    && success "elliemayphotos.com → latest deployment" \
    || warn "Failed to alias elliemayphotos.com"
fi

echo ""
success "All done! 🎉"
echo ""
echo "  🌐  Live URL : https://www.elliemayphotos.com"
echo "  📁  GitHub   : https://github.com/elliesophiamay/ellie-may-photography"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
