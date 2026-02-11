source "${HOME}/.config/easily/.env"

easily.caddy.site_dir() {
  echo "${EASILY_ROOT}/config/caddy/sites"
}

easily.caddy.site_file() {
  local project_id="$1"
  echo "$(easily.caddy.site_dir)/${project_id}.caddy"
}

easily.caddy.ensure_site_dir() {
  mkdir -p "$(easily.caddy.site_dir)"
}

easily.caddy.normalize_domain() {
  local raw_domain="$1"
  raw_domain="${raw_domain#http://}"
  raw_domain="${raw_domain#https://}"
  raw_domain="${raw_domain%%/*}"
  echo "${raw_domain}"
}

easily.caddy.write_route() {
  local project_id="$1"
  local domain="$2"

  if [ -z "${project_id}" ] || [ -z "${domain}" ]; then
    return 1
  fi

  local route_file
  route_file="$(easily.caddy.site_file "${project_id}")"

  easily.caddy.ensure_site_dir

  cat > "${route_file}" <<EOF_ROUTE
${domain} {
  tls internal
  reverse_proxy ${project_id}-app-1:80
}
EOF_ROUTE
}

easily.caddy.remove_route() {
  local project_id="$1"
  if [ -z "${project_id}" ]; then
    return 0
  fi

  local route_file
  route_file="$(easily.caddy.site_file "${project_id}")"
  rm -f "${route_file}"
}

easily.caddy.reload() {
  local core_compose="${EASILY_ROOT}/config/compose.yaml"

  if ! docker compose -f "${core_compose}" -p easily ps -q caddy | grep -q .; then
    return 0
  fi

  docker compose -f "${core_compose}" -p easily exec -T caddy caddy reload --config /etc/caddy/Caddyfile >/dev/null 2>&1 || \
    docker compose -f "${core_compose}" -p easily restart caddy >/dev/null 2>&1
}
