#!/usr/bin/env bash
set -euo pipefail

ENV_FILE=${ENV_FILE:-firebase_keys.env}

if [[ ! -f "$ENV_FILE" ]]; then
  echo "❌ Env file '$ENV_FILE' not found."
  echo "   Copy firebase_keys.env.example to $ENV_FILE and fill in your values."
  exit 1
fi

if [[ $# -lt 1 ]]; then
  echo "Usage: scripts/flutter_with_env.sh <flutter_command> [args...]"
  echo "Example: scripts/flutter_with_env.sh run -d chrome"
  exit 1
fi

COMMAND=$1
shift

flutter "$COMMAND" "$@" --dart-define-from-file="$ENV_FILE"
