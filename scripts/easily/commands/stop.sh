source "${HOME}/.config/easily/.env"
source "${EASILY_ROOT}/scripts/easily/caddy.sh"

easily.stop.project() {
  local requested_project="${1:-}"

  source "${EASILY_ROOT}/scripts/easily/definitions.sh" "${requested_project}" || return 0

  if [ -z "${project_id}" ]; then
    echo.warning "Unable to resolve project '${requested_project}'."
    return 0
  fi

  echo.info "Stopping ${project_name}..."

  if [ -f "${compose_file}" ]; then
    docker compose -f "${compose_file}" -p "${project_id}" stop || return 1
  fi

  easily.caddy.remove_route "${project_id}"
  easily.caddy.reload

  echo.success "Stopped ${project_name}."
}

function easily.stop() {
  local LOCK="${EASILY_ROOT}/.easily.running.lock"
  local requested_project="${1:-}"
  local targets=()
  local target

  if [ -z "${requested_project}" ]; then
    if [ ! -f "${LOCK}" ]; then
      echo.danger "No arguments supplied or no project running"
      easily help
      return 0
    fi

    source "${LOCK}"
    while IFS= read -r target; do
      [ -n "${target}" ] && targets+=("${target}")
    done < <(printf '%s\n' "${EASILY_RUNNING}" | tr ' ' '\n')
  elif [ "${requested_project}" = "all" ]; then
    while IFS= read -r target; do
      [ -n "${target}" ] && targets+=("${target}")
    done < <(find "${EASILY_ROOT}/projects" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | LC_ALL=C sort)
  else
    targets=("${requested_project}")
  fi

  if [ "${#targets[@]}" -eq 0 ]; then
    echo.warning "No projects to stop."
    return 0
  fi

  for target in "${targets[@]}"; do
    easily.stop.project "${target}" || return 1
  done

  unalias composer 2>/dev/null
  unalias npm 2>/dev/null
  unalias php 2>/dev/null
  unalias p 2>/dev/null
  unalias pf 2>/dev/null
  unalias art 2>/dev/null

  rm -f "${LOCK}"
}

easily.stop "$2"
