#!/usr/bin/env sh

error_status=0
success_emoji=✅
fail_emoji=❌

run() {
  eval "${@}"
  last_exit_status=${?}

  if [ ${last_exit_status} -ne 0 ]; then
    echo "Something went wrong. Program exited with ${last_exit_status}"
    error_status=${last_exit_status}
  else
    echo ${success_emoji}
  fi
}

separator() {
  index=0

  while [ $index -le "${1}" ]; do
    printf "–"
    index=$((index + 1))
  done

  echo ""
}

header() {
  chrlen=$((${#1} + 10))
  separator ${chrlen}
  echo "     $1     "
  separator ${chrlen}
}

header "API tests…"
run mix test

header "Compilation without warnings…"
run mix compile --warnings-as-errors --force

header "API code auto-formatting…"
run mix format --dry-run --check-formatted

header "API code lint…"
run mix credo --strict

header "Webapp code auto-formatting…"
run npm --prefix webapp run prettier-check

header "Webapp code lint…"
run npm --prefix webapp run lint

header "Webapp tests…"
run npm --prefix webapp test

if [ ${error_status} -ne 0 ]; then
  header "${fail_emoji}   Something went wrong. Please fix it before committing."
else
  header "${success_emoji}   Everything looks good!"
fi

exit $error_status
