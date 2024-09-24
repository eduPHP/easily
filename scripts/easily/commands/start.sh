EASILY_ROOT="${HOME}/code/docker"
function easily.sstart() {
  source "${EASILY_ROOT}/scripts/easily/definitions.sh" || return 0

  # create network if it doesn't exist
  if [ -z $(docker network ls --format "{{.Name}}" | grep easily) ]; then
      docker network create easily --attachable
  fi
  # stop previously running project
  local LOCK="${EASILY_ROOT}/.easily.running.lock"
  if [ -f "$LOCK" ]; then
    source "${EASILY_ROOT}/.easily.running.lock"
    if [ "easily" != "$EASILY_RUNNING" ]; then
      echo.warning "$EASILY_RUNNING is already running, stopping it first..."
      easily stop $EASILY_RUNNING
    fi
  fi
  echo.info "Setting up Easily..."
  # Create local dertificates if it doesn't exist
  if [ ! -f "${EASILY_ROOT}/config/nginx/certs/${domain}.csr" ]; then
    echo.info "Certificates doesn't exist, creating..."
    eval "sh ${EASILY_ROOT}/scripts/cert.sh easily ${domain}"
  fi
  source "${EASILY_ROOT}/stubs/.aliases"
  if [ -f "${project_dir}/.aliases" ]; then
    source "${project_dir}/.aliases"
  fi

  eval docker compose -f ${EASILY_ROOT}/config/compose.yaml -p easily up -d --remove-orphans

  if [ -n $local_command ]; then
    echo.warning "local command exists: '${local_command}'"
#    eval ${local_command} -p ${project_id} up -d --remove-orphans
  fi
  echo.success "${project_name} initialized!"

  if [ -f "${project_dir}/.run-after-start" ]; then
    sh "${project_dir}/.run-after-start"
  fi
#  python3 -m webbrowser "https://${domain}"
}
easily.sstart
