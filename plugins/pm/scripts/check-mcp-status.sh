#!/usr/bin/env bash
# PM Plugin — MCP Status Check
# Runs on SessionStart, shows which integrations are configured

set -euo pipefail

# Colors
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
BOLD="\033[1m"
RESET="\033[0m"

check_var() {
  local name="$1"
  if [ -n "${!name:-}" ]; then
    echo "ok"
  else
    echo "missing"
  fi
}

# Check each integration
jira_url=$(check_var "JIRA_URL")
jira_token=$(check_var "JIRA_TOKEN")
jira_email=$(check_var "JIRA_USER_EMAIL")

conf_url=$(check_var "CONFLUENCE_URL")
conf_token=$(check_var "CONFLUENCE_TOKEN")
conf_email=$(check_var "CONFLUENCE_USER_EMAIL")

sentry_token=$(check_var "SENTRY_TOKEN")
sentry_org=$(check_var "SENTRY_ORG")

github_token=$(check_var "GITHUB_TOKEN")

# Determine status per integration
status_icon() {
  local -a vars=("$@")
  local all_ok=true
  local any_ok=false

  for v in "${vars[@]}"; do
    if [ "$v" = "ok" ]; then
      any_ok=true
    else
      all_ok=false
    fi
  done

  if $all_ok; then
    echo -e "${GREEN}✅ connected${RESET}"
  elif $any_ok; then
    echo -e "${YELLOW}⚠️  partial${RESET}"
  else
    echo -e "${RED}❌ not configured${RESET}"
  fi
}

missing_vars() {
  local -a names=("$@")
  local missing=()
  for name in "${names[@]}"; do
    if [ -z "${!name:-}" ]; then
      missing+=("$name")
    fi
  done
  if [ ${#missing[@]} -gt 0 ]; then
    echo "  missing: ${missing[*]}"
  fi
}

jira_status=$(status_icon "$jira_url" "$jira_token" "$jira_email")
conf_status=$(status_icon "$conf_url" "$conf_token" "$conf_email")
sentry_status=$(status_icon "$sentry_token" "$sentry_org")
git_status=$(status_icon "$github_token")

# Count issues
has_issues=false
if [ "$jira_url" = "missing" ] || [ "$jira_token" = "missing" ] || [ "$jira_email" = "missing" ] || \
   [ "$conf_url" = "missing" ] || [ "$conf_token" = "missing" ] || [ "$conf_email" = "missing" ] || \
   [ "$sentry_token" = "missing" ] || [ "$sentry_org" = "missing" ] || \
   [ "$github_token" = "missing" ]; then
  has_issues=true
fi

# Output
echo ""
echo -e "${BOLD}📋 PM Plugin — MCP Status${RESET}"
echo ""
echo -e "  Jira        $jira_status"
[ "$jira_url" = "missing" ] || [ "$jira_token" = "missing" ] || [ "$jira_email" = "missing" ] && \
  missing_vars "JIRA_URL" "JIRA_TOKEN" "JIRA_USER_EMAIL" | grep -v "^$"

echo -e "  Confluence  $conf_status"
[ "$conf_url" = "missing" ] || [ "$conf_token" = "missing" ] || [ "$conf_email" = "missing" ] && \
  missing_vars "CONFLUENCE_URL" "CONFLUENCE_TOKEN" "CONFLUENCE_USER_EMAIL" | grep -v "^$"

echo -e "  Sentry      $sentry_status"
[ "$sentry_token" = "missing" ] || [ "$sentry_org" = "missing" ] && \
  missing_vars "SENTRY_TOKEN" "SENTRY_ORG" | grep -v "^$"

echo -e "  Git         $git_status"
[ "$github_token" = "missing" ] && \
  missing_vars "GITHUB_TOKEN" | grep -v "^$"

echo ""

if $has_issues; then
  echo -e "${YELLOW}Run /pm:setup to configure missing integrations${RESET}"
  echo -e "Plugin works without MCP — in dialogue mode with reduced context."
else
  echo -e "${GREEN}All integrations configured. Ready to go.${RESET}"
fi
echo ""
