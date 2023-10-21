EASILY_ROOT="${HOME}/code/docker"

function easilyStop() {
  local LOCK="${EASILY_ROOT}/.easily.running.lock"

  if [ $# -eq 0 ]; then
      if [ ! -f $LOCK ]; then
        echo "No arguments supplied or no project running"
        easily help
        return 0
      else
        source $LOCK
        # bad code?
        1=$EASILY_RUNNING
      fi
  fi

  source "${EASILY_ROOT}/scripts/easily/definitions.sh" || return 0

  local docker_compose="~/code/docker/projects/${project_id}/docker-compose.yml"
  local project_alias="$(tr "[A-Z]" "[a-z]" <<< "${project_name}")"
  local command="docker-compose -f $docker_compose"

  echo -e "\033[0;33m Stopping ${project_name}..."

  eval "${command} -p ${project_alias} kill"

  # unset aliases
  unalias composer 2>/dev/null
  unalias npm 2>/dev/null
  unalias php 2>/dev/null
  unalias p 2>/dev/null
  unalias pf 2>/dev/null
  unalias art 2>/dev/null

  rm -f $LOCK
  echo -e "\033[0;33m Stopped ${project_name}..."
}

easilyStop $2