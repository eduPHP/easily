EASILY_ROOT="${HOME}/code/docker"

function easilyRemove() {
  if [ $# -eq 0 ]
    then
      echo.danger "No arguments supplied"
      easily help
      return 0
  fi
  source "${EASILY_ROOT}/scripts/easily/definitions.sh" || return 0

  echo "Are you sure? [y/n]"
  read response
  if [[ "$response" =~ ^([yY][sS]|[yY])$ ]]; then
    echo.info "Removing ${project_name}"

    eval "${command} -p ${project_alias} rm -fsv"
    rm -rf "${EASILY_ROOT}/projects/${project_id}"

    echo.success "Removed ${project_name}"
  else
    echo.info "Cancelled"
  fi
}

easilyRemove $2