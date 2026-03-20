#!/usr/bin/env bash
# Fake LanguageTool Java process for testing the Port protocol.
# Mimics the stdin/stdout line protocol used by App.kt.

printf ">\n"

while IFS= read -r line; do
  lang="${line:0:7}"
  lang="${lang// /}"
  text="${line:7}"

  case "$lang" in
    "malform")
      printf 'not valid json{{\n'
      ;;
    "crash_")
      exit 1
      ;;
    "slow__")
      sleep 2
      printf '{"language":"%s","text":"slow_response","matches":[],"markups":[]}\n' "$lang"
      ;;
    *)
      if [ -z "$text" ]; then
        printf '{"error":"invalid_input","text":"","language":"%s","matches":[],"markups":[]}\n' "$lang"
      else
        printf '{"language":"%s","text":"fake_response","matches":[],"markups":[]}\n' "$lang"
      fi
      ;;
  esac
done
