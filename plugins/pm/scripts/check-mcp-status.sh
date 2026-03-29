#!/usr/bin/env bash
# PM Plugin — MCP Status Check
# Runs on SessionStart, shows which integrations are configured

set -euo pipefail

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
BOLD="\033[1m"
RESET="\033[0m"

check_var() {
  local name="$1"
  if [ -n "${!name:-}" ]; then echo "ok"; else echo "missing"; fi
}

# Jira
jira_site=$(check_var "ATLASSIAN_JIRA_SITE_NAME")
jira_email=$(check_var "ATLASSIAN_USER_EMAIL")
jira_token=$(check_var "ATLASSIAN_API_TOKEN")

# Confluence
conf_site=$(check_var "ATLASSIAN_CONFLUENCE_SITE_NAME")

# Sentry
sentry_token=$(check_var "SENTRY_ACCESS_TOKEN")
sentry_org=$(check_var "SENTRY_ORG")

# GitHub
github_token=$(check_var "GITHUB_PERSONAL_ACCESS_TOKEN")

status_icon() {
  local all_ok=true any_ok=false
  for v in "$@"; do
    if [ "$v" = "ok" ]; then any_ok=true; else all_ok=false; fi
  done
  if $all_ok; then echo -e "${GREEN}✅ ready${RESET}"
  elif $any_ok; then echo -e "${YELLOW}⚠️  partial${RESET}"
  else echo -e "${RED}❌ not configured${RESET}"
  fi
}

missing_list() {
  local missing=()
  for name in "$@"; do
    if [ -z "${!name:-}" ]; then missing+=("$name"); fi
  done
  if [ ${#missing[@]} -gt 0 ]; then
    echo "              missing: ${missing[*]}"
  fi
}

jira_status=$(status_icon "$jira_site" "$jira_email" "$jira_token")
conf_status=$(status_icon "$conf_site" "$jira_email" "$jira_token")
sentry_status=$(status_icon "$sentry_token" "$sentry_org")
github_status=$(status_icon "$github_token")

echo ""
echo -e "${BOLD}📋 PM Plugin — MCP Connectors${RESET}"
echo ""
echo -e "  Jira          $jira_status"
[ "$jira_site" = "missing" ] || [ "$jira_email" = "missing" ] || [ "$jira_token" = "missing" ] && \
  missing_list ATLASSIAN_JIRA_SITE_NAME ATLASSIAN_USER_EMAIL ATLASSIAN_API_TOKEN
echo -e "  Confluence    $conf_status"
[ "$conf_site" = "missing" ] || [ "$jira_email" = "missing" ] || [ "$jira_token" = "missing" ] && \
  missing_list ATLASSIAN_CONFLUENCE_SITE_NAME ATLASSIAN_USER_EMAIL ATLASSIAN_API_TOKEN
echo -e "  Sentry        $sentry_status"
[ "$sentry_token" = "missing" ] || [ "$sentry_org" = "missing" ] && \
  missing_list SENTRY_ACCESS_TOKEN SENTRY_ORG
echo -e "  GitHub        $github_status"
[ "$github_token" = "missing" ] && missing_list GITHUB_PERSONAL_ACCESS_TOKEN
echo ""

has_issues=false
[ "$jira_site" = "missing" ] || [ "$jira_email" = "missing" ] || [ "$jira_token" = "missing" ] && has_issues=true
[ "$conf_site" = "missing" ] && has_issues=true
[ "$sentry_token" = "missing" ] || [ "$sentry_org" = "missing" ] && has_issues=true
[ "$github_token" = "missing" ] && has_issues=true

if $has_issues; then
  echo -e "${YELLOW}Run /pm:setup to configure missing env vars${RESET}"
  echo -e "Plugin works without full MCP — in dialogue mode for missing sources."
else
  echo -e "${GREEN}All connectors configured.${RESET}"
fi
echo ""
