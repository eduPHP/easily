EASILY_ROOT="${HOME}/code/docker"

function easily.start() {
  if [ $# -eq 0 ]
    then
      echo.danger "No arguments supplied"
      easily help
      return 0
  fi

  source "${EASILY_ROOT}/scripts/easily/definitions.sh" || return 0

  local LOCK="${EASILY_ROOT}/.easily.running.lock"

  # stop previously running project
  if [ -f "$LOCK" ]; then
    source "${EASILY_ROOT}/.easily.running.lock"

    if [ "$project_id" != "$EASILY_RUNNING" ]; then
      echo.warning "$EASILY_RUNNING is already running, stopping it first..."
      easily stop $EASILY_RUNNING
    fi
  fi

  echo.info "Setting up ${project_name}..."

  # Create local dertificates if it doesn't exist
  if [ ! -f "${project_dir}/certs/cert.csr" ]; then
    echo.info "Certificates doesn't exist, creating..."
    eval "sh ${EASILY_ROOT}/scripts/cert.sh ${project_id}"
  fi

  if [ -f "${project_dir}/.aliases" ]; then
    source "${project_dir}/.aliases"
  else
    source "${EASILY_ROOT}/stubs/.aliases"
  fi

  source "$project_dir/.env"

  if [ -d $SERVER_ROOT ]; then
      cd $SERVER_ROOT
    else
      echo.danger "SERVER_ROOT not found, please create your project at $SERVER_ROOT and try again"
      return 1
  fi

  eval ${command} -p ${project_alias} up -d
  echo.success "${project_name} initialized!"

  echo "EASILY_RUNNING=$project_id" > $LOCK
}

easily.start $2