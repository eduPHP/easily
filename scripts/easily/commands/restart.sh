source "${HOME}/.config/easily/.env"

function easily.restart() {
  local LOCK="${EASILY_ROOT}/.easily.running.lock"
  local requested_project="${1:-}"

  if [ -z "${requested_project}" ]; then
    if [ ! -f "${LOCK}" ]; then
      echo.danger "No arguments supplied or no project running"
      easily help
      return 0
    fi

    source "${LOCK}"
    if [[ "${EASILY_RUNNING}" == *" "* ]]; then
      requested_project="all"
    else
      requested_project="${EASILY_RUNNING}"
    fi
  fi

  easily stop "${requested_project}" || return 1
  easily start "${requested_project}"
}

easily.restart "$2"
