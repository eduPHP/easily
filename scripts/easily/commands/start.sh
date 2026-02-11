source "${HOME}/.config/easily/.env"

function easily.start() {
  local requested_project="${1:-}"
  local LOCK="${EASILY_ROOT}/.easily.running.lock"

  # create network if it doesn't exist
  if ! docker network inspect easily >/dev/null 2>&1; then
      docker network create easily --attachable >/dev/null
  fi
  docker compose -f "${EASILY_ROOT}/config/compose.yaml" -p easily up -d --remove-orphans || return 1

  source "${EASILY_ROOT}/scripts/easily/definitions.sh" "${requested_project}" || return 1

  echo.info "Setting up Easily..."

  if [ -z "${project_id}" ]; then
    echo.warning "No project resolved. Core services are running."
    return 0
  fi

  if [ -n "${domain}" ] && [ ! -f "${EASILY_ROOT}/config/nginx/certs/${domain}.csr" ]; then
    echo.info "Certificates doesn't exist, creating..."
    EASILY_ROOT="${EASILY_ROOT}" /usr/bin/bash -c "${EASILY_ROOT}/scripts/cert.sh ${domain} ${domain}"
  elif [ -z "${domain}" ]; then
    echo.warning "No domain configured for ${project_id}; skipping certificate generation."
  fi

  source "${EASILY_ROOT}/stubs/.aliases"
  if [ -f "${project_dir}/.aliases" ]; then
    source "${project_dir}/.aliases" 2>/dev/null
  fi

  if [ -f "${compose_file}" ]; then
    local services
    local compose_env=()
    services="$(docker compose -f "${compose_file}" config --services 2>/dev/null || true)"

    if printf '%s\n' "${services}" | grep -qx 'app' && printf '%s\n' "${services}" | grep -qx 'php'; then
      if [ -z "${APP_PORT}" ] && ss -ltn '( sport = :80 )' | tail -n +2 | grep -q .; then
        compose_env+=("APP_PORT=8080")
        echo.warning "Port 80 is busy; using APP_PORT=8080 for ${project_id}."
      fi

      if [ -z "${APP_SSL_PORT}" ] && ss -ltn '( sport = :443 )' | tail -n +2 | grep -q .; then
        compose_env+=("APP_SSL_PORT=8443")
        echo.warning "Port 443 is busy; using APP_SSL_PORT=8443 for ${project_id}."
      fi

      env "${compose_env[@]}" docker compose -f "${compose_file}" -p "${project_id}" up -d --remove-orphans --no-deps php app || return 1
    else
      docker compose -f "${compose_file}" -p "${project_id}" up -d --remove-orphans || return 1
    fi
  fi

  echo "EASILY_RUNNING=${project_id}" > "${LOCK}"
  echo.success "${project_name} initialized!"

  if [ -f "${project_dir}/.run-after-start" ]; then
    sh "${project_dir}/.run-after-start"
  fi
#  python3 -m webbrowser "https://${domain}"
}
easily.start "$2"
