#!/usr/bin/env bash
set -euo pipefail

branch="$(git branch --show-current)"
changes="$(git status --short)"
context="Branch: ${branch:-<detached HEAD>}"
if [[ -n "$changes" ]]; then
  context+=$'\nUncommitted changes:\n'"$changes"
else
  context+=$'\nWorking tree: clean'
fi
context+=$'\nWorkflow: discover > accept > tdd > review'
jq -cn --arg context "$context" '{additionalContext:$context}'
