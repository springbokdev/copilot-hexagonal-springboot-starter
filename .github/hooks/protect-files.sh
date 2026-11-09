#!/usr/bin/env bash
set -euo pipefail

input="$(cat)"
tool_name="$(jq -er '.toolName' <<<"$input")"
tool_args="$(jq -c '.toolArgs // {}' <<<"$input")"
command="$(jq -r '.toolArgs | if type == "object" then (.command // .script // "") elif type == "string" then . else "" end' <<<"$input")"
target_path="$(jq -r '.toolArgs | if type == "object" then (.filePath // .file_path // .path // .targetPath // .uri // "") else "" end' <<<"$input")"
file_tool=false
case "$tool_name" in
  edit|create|write|apply_patch|str_replace_editor) file_tool=true ;;
esac

normalize() {
  printf '%s' "$1" | tr '\\' '/' | tr '[:upper:]' '[:lower:]'
}

check_sensitive() {
  local value
  value="$(normalize "$1")"
  [[ "$value" == *".env"* || "$value" =~ \.(pem|key|p12|jks|keystore|truststore)([^a-z0-9_]|$) ]]
}

check_protected() {
  local value
  value="$(normalize "$1")"
  [[ "$value" == *"application-prod"* ||
     "$value" == *"application-secrets"* ||
     "$value" == *".mvn/"* ||
     "$value" == *"mvnw"* ||
     "$value" == *".github/workflows"* ||
     "$value" == *".github/hooks"* ||
     "$value" == *".git/"* ||
     "$value" == *"dockerfile"* ||
     "$value" == *"docker-compose"* ]]
}

is_mutating_command() {
  [[ "$1" =~ (\>|sed[[:space:]]+-i|perl[[:space:]]+-i|(^|[[:space:]\|\;])(tee|mv|cp|rm|dd|install|truncate|chmod|chown)([[:space:]]|$)|git[[:space:]]+(rm|mv|clean|checkout|restore)([[:space:]]|$)|(^|[[:space:]\|\;])(set-content|out-file|add-content|move-item|copy-item|remove-item|new-item|clear-content|rename-item)([[:space:]]|$)) ]]
}

candidate="$tool_args"
if [[ "$file_tool" == true && -n "$target_path" ]]; then
  candidate="$target_path"
fi
if [[ "$tool_name" == "bash" || "$tool_name" == "powershell" ]]; then
  candidate="$command"
fi

reason=""
if check_sensitive "$candidate"; then
  reason="Sensitive environment or key material must not be accessed by an agent tool."
elif { "$file_tool" || is_mutating_command "$command"; } && check_protected "$candidate"; then
  reason="Changes to protected build, deployment, hook, or version-control paths are blocked."
fi

if [[ -n "$reason" ]]; then
  jq -cn --arg reason "$reason" \
    '{permissionDecision:"deny", permissionDecisionReason:$reason}'
fi
