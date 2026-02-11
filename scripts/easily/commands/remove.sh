source "${HOME}/.config/easily/.env"
source "${EASILY_ROOT}/scripts/easily/caddy.sh"

function easily.remove() {
  local requested_project="${1:-}"

  if [ -z "${requested_project}" ]; then
      echo.danger "No arguments supplied"
      easily help
      return 0
  fi

  source "${EASILY_ROOT}/scripts/easily/definitions.sh" "${requested_project}" || return 0

  if [ -z "${project_id}" ]; then
    echo.warning "Unable to resolve project '${requested_project}'."
    return 0
  fi

  echo "Are you sure? [y/n]"
  read -r response
  if [[ "${response}" =~ ^([yY][sS]|[yY])$ ]]; then
    echo.info "Removing ${project_name}"

    if [ -f "${compose_file}" ]; then
      docker compose -f "${compose_file}" -p "${project_id}" rm -fsv
    fi

    easily.caddy.remove_route "${project_id}"
    easily.caddy.reload

    rm -rf "${EASILY_ROOT}/projects/${project_id}"
    echo.success "Removed ${project_name}"
  else
    echo.info "Cancelled"
  fi
}

easily.remove "$2"
