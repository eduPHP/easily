EASILY_ROOT="${HOME}/code/docker"

function easily.stop() {
  local LOCK="${EASILY_ROOT}/.easily.running.lock"

  if [ $# -eq 0 ]; then
      if [ ! -f $LOCK ]; then
        echo.danger "No arguments supplied or no project running"
        easily help
        return 0
      else
        source $LOCK
        set -- $EASILY_RUNNING
      fi
  fi

  source "${EASILY_ROOT}/scripts/easily/definitions.sh" || return 0

  local docker_compose="~/code/docker/projects/${project_id}/docker-compose.yml"
  local project_alias="$(tr "[A-Z]" "[a-z]" <<< "${project_name}")"
  local command="docker-compose -f $docker_compose"

  echo.info "Stopping ${project_name}..."

  eval "${command} -p ${project_alias} kill"

  # unset aliases
  unalias composer 2>/dev/null
  unalias npm 2>/dev/null
  unalias php 2>/dev/null
  unalias p 2>/dev/null
  unalias pf 2>/dev/null
  unalias art 2>/dev/null

  rm -f $LOCK
  echo.success "Stopped ${project_name}..."
}

easily.stop $2