#!/bin/bash

# Setze BASE_URL mit Prefix
ABACUS_BASE_URL="https://api.abacus.ai/api/v0"

# Parse command line arguments
OLDER_THAN_DAYS=""
DRY_RUN=false
API_KEY_ARG=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --older-than)
      OLDER_THAN_DAYS="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --api-key)
      API_KEY_ARG="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--older-than DAYS] [--dry-run] [--api-key KEY]"
      exit 1
      ;;
  esac
done

# API Key Priorität: 1. Command line argument, 2. Umgebungsvariable, 3. Interaktive Abfrage
if [ -n "$API_KEY_ARG" ]; then
  ABACUS_API_KEY="$API_KEY_ARG"
elif [ -z "$ABACUS_API_KEY" ]; then
  read -rsp "Enter your Abacus API Key: " ABACUS_API_KEY
  echo
fi

# 1. Projekte abrufen
echo "Fetching projects..."
projects_response=$(curl -s -X GET "$ABACUS_BASE_URL/listProjects" -H "apiKey: $ABACUS_API_KEY")
projectId=$(echo "$projects_response" | jq -r '.result[0].projectId')

if [ -z "$projectId" ] || [ "$projectId" == "null" ]; then
  echo "Keine projectId gefunden!"
  exit 1
fi
echo "projectId: $projectId"

# 2. Deployments abrufen
echo "Fetching deployments..."
deployments_response=$(curl -s -X GET "$ABACUS_BASE_URL/listDeployments?projectId=$projectId" -H "apiKey: $ABACUS_API_KEY")
chatLLMDeploymentId=$(echo "$deployments_response" | jq -r '.result[] | select(.name == "ChatLLM Deployment") | .deploymentId')

if [ -z "$chatLLMDeploymentId" ] || [ "$chatLLMDeploymentId" == "null" ]; then
  echo "ChatLLM Deployment nicht gefunden!"
  exit 1
fi
echo "chatLLMDeploymentId: $chatLLMDeploymentId"

# 3. Sessions abrufen
echo "Fetching sessions..."
sessions_response=$(curl -s -X GET "$ABACUS_BASE_URL/listDeploymentConversations?deploymentId=$chatLLMDeploymentId" -H "apiKey: $ABACUS_API_KEY")

# Wenn --older-than angegeben wurde, filtere und lösche alte Chats
if [ -n "$OLDER_THAN_DAYS" ]; then
  echo "Filtering chats older than $OLDER_THAN_DAYS days..."

  # Berechne das Cutoff-Datum (jetzt - OLDER_THAN_DAYS)
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    cutoff_date=$(date -u -v-${OLDER_THAN_DAYS}d +"%Y-%m-%dT%H:%M:%S")
  else
    # Linux
    cutoff_date=$(date -u -d "$OLDER_THAN_DAYS days ago" +"%Y-%m-%dT%H:%M:%S")
  fi

  echo "Cutoff date: $cutoff_date"

  # Extrahiere alte Sessions mit jq
  old_sessions=$(echo "$sessions_response" | jq -r --arg cutoff "$cutoff_date" \
    '.result[] | select(.createdAt < $cutoff) | "\(.deploymentConversationId)|\(.name)|\(.createdAt)"')

  if [ -z "$old_sessions" ]; then
    echo "No sessions older than $OLDER_THAN_DAYS days found."
  else
    session_count=$(echo "$old_sessions" | wc -l | tr -d ' ')
    echo "Found $session_count session(s) to delete:"
    echo "$old_sessions" | while IFS='|' read -r sessionId name createdAt; do
      echo "  - $name (ID: $sessionId, Created: $createdAt)"
    done

    if [ "$DRY_RUN" = true ]; then
      echo ""
      echo "DRY RUN: No sessions were deleted. Remove --dry-run to actually delete."
    else
      echo ""
      read -p "Do you want to delete these $session_count session(s)? (yes/no): " confirmation
      if [ "$confirmation" = "yes" ]; then
        echo "Deleting sessions..."
        echo "$old_sessions" | while IFS='|' read -r sessionId name createdAt; do
          echo "Deleting session: $name (ID: $sessionId)"
          delete_response=$(curl -s -X DELETE "$ABACUS_BASE_URL/deleteDeploymentConversation?deploymentConversationId=$sessionId" -H "apiKey: $ABACUS_API_KEY")
          if echo "$delete_response" | jq -e '.success == true' > /dev/null 2>&1; then
            echo "  ✓ Successfully deleted"
          else
            echo "  ✗ Failed to delete"
          fi
        done
        echo "Deletion complete."
      else
        echo "Deletion cancelled."
      fi
    fi
  fi
else
  # Ohne --older-than: Zeige alle Sessions
  echo "$sessions_response" | jq

  # Optional: Alle deploymentConversationIds extrahieren
  sessionIds=$(echo "$sessions_response" | jq -r '.result[].deploymentConversationId')
fi
