source "${HOME}/.config/easily/.env"
source "${EASILY_ROOT}/scripts/easily/caddy.sh"

easily.start.project() {
  local requested_project="${1:-}"
  local LOCK="${EASILY_ROOT}/.easily.running.lock"

  source "${EASILY_ROOT}/scripts/easily/definitions.sh" "${requested_project}" || return 1

  if [ -z "${project_id}" ]; then
    echo.warning "No project resolved. Core services are running."
    return 0
  fi

  local services
  local has_app_php="false"
  local resolved_domain="${APP_DOMAIN:-$domain}"

  resolved_domain="$(easily.caddy.normalize_domain "${resolved_domain}")"
  if [ -z "${resolved_domain}" ]; then
    resolved_domain="${project_id}.test"
    echo.warning "No domain configured for ${project_id}; defaulting to ${resolved_domain}."
  fi

  source "${EASILY_ROOT}/stubs/.aliases"
  if [ -n "${project_dir}" ] && [ -f "${project_dir}/.aliases" ]; then
    source "${project_dir}/.aliases" 2>/dev/null
  fi

  if [ -n "${project_dir}" ] && [ ! -f "${compose_file}" ]; then
    cp "${EASILY_ROOT}/stubs/compose.yaml" "${compose_file}" || return 1
    echo.info "Created compose stub for ${project_id}."
  fi

  if [ -f "${compose_file}" ]; then
    services="$(docker compose -f "${compose_file}" config --services 2>/dev/null || true)"
    if printf '%s\n' "${services}" | grep -qx 'app' && printf '%s\n' "${services}" | grep -qx 'php'; then
      has_app_php="true"
      env "APP_DOMAIN=${resolved_domain}" docker compose -f "${compose_file}" -p "${project_id}" up -d --remove-orphans --no-deps php app || return 1
    else
      docker compose -f "${compose_file}" -p "${project_id}" up -d --remove-orphans || return 1
    fi
  fi

  if [ "${has_app_php}" = "true" ]; then
    easily.caddy.write_route "${project_id}" "${resolved_domain}" || return 1
    easily.caddy.reload
  fi

  echo "EASILY_RUNNING=${project_id}" > "${LOCK}"
  echo.success "${project_name} initialized on https://${resolved_domain}!"

  if [ -n "${project_dir}" ] && [ -f "${project_dir}/.run-after-start" ]; then
    sh "${project_dir}/.run-after-start"
  fi
}

easily.start.all() {
  local LOCK="${EASILY_ROOT}/.easily.running.lock"
  local projects_root="${EASILY_ROOT}/projects"
  local project_ids=()
  local started_ids=()
  local project_id

  if [ ! -d "${projects_root}" ]; then
    echo.warning "No projects directory found at ${projects_root}."
    return 0
  fi

  while IFS= read -r project_id; do
    [ -n "${project_id}" ] && project_ids+=("${project_id}")
  done < <(find "${projects_root}" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | LC_ALL=C sort)

  if [ "${#project_ids[@]}" -eq 0 ]; then
    echo.warning "No projects found in ${projects_root}."
    return 0
  fi

  for project_id in "${project_ids[@]}"; do
    echo.info "Starting ${project_id}..."
    easily.start.project "${project_id}" || return 1
    started_ids+=("${project_id}")
  done

  echo "EASILY_RUNNING=${started_ids[*]}" > "${LOCK}"
  echo.success "Started ${#started_ids[@]} projects."
}

function easily.start() {
  local requested_project="${1:-}"
  local core_env=()

  if ! docker network inspect easily >/dev/null 2>&1; then
      docker network create easily --attachable >/dev/null
  fi

  if [ -z "${EASILY_HTTP_PORT}" ] && ss -ltn '( sport = :80 )' | tail -n +2 | grep -q .; then
    core_env+=("EASILY_HTTP_PORT=8080")
    echo.warning "Port 80 is busy; using EASILY_HTTP_PORT=8080."
  fi

  if [ -z "${EASILY_HTTPS_PORT}" ] && ss -ltn '( sport = :443 )' | tail -n +2 | grep -q .; then
    core_env+=("EASILY_HTTPS_PORT=8443")
    echo.warning "Port 443 is busy; using EASILY_HTTPS_PORT=8443."
  fi

  env "${core_env[@]}" docker compose -f "${EASILY_ROOT}/config/compose.yaml" -p easily up -d --remove-orphans || return 1

  echo.info "Setting up Easily..."

  if [ "${requested_project}" = "all" ]; then
    easily.start.all
    return $?
  fi

  easily.start.project "${requested_project}"
}

easily.start "$2"
