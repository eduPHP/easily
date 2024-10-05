source "${HOME}/.config/easily/.env"
function easily.start() {
  # create network if it doesn't exist
  if [ -z $(docker network ls --format "{{.Name}}" | grep easily) ]; then
      docker network create easily --attachable
  fi
  eval docker compose -f ${EASILY_ROOT}/config/compose.yaml -p easily up -d --remove-orphans

  source "${EASILY_ROOT}/scripts/easily/definitions.sh" || return 0

  echo.info "Setting up Easily..."
  # Create local dertificates if it doesn't exist
  if [ ! -f "${EASILY_ROOT}/config/nginx/certs/${domain}.csr" ]; then
    echo.info "Certificates doesn't exist, creating..."
    exec "sh ${EASILY_ROOT}/scripts/cert.sh easily ${domain}"
  fi
  source "${EASILY_ROOT}/stubs/.aliases"
  if [ -f "${project_dir}/.aliases" ]; then
    source "${project_dir}/.aliases"
  fi

  if [ -f "${projects_dir}/${project_id}/compose.yaml" ]; then
    local local_command="docker compose -f ${projects_dir}/${project_id}/compose.yaml"
    eval ${local_command} -p ${project_id} up -d --remove-orphans
  fi
  echo.success "${project_name} initialized!"

  if [ -f "${project_dir}/.run-after-start" ]; then
    sh "${project_dir}/.run-after-start"
  fi
#  python3 -m webbrowser "https://${domain}"
}
easily.start
