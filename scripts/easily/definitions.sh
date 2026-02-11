source "${HOME}/.config/easily/.env"
requested_project="${1:-}"
SERVER_ROOT="$(pwd)"

projects_dir="${EASILY_ROOT}/projects"
config_file="${projects_dir}/config.json"

mkdir -p "${projects_dir}"

if [ ! -f "${config_file}" ]; then
  echo '{"projects":{}}' > "${config_file}"
fi

project_json=""
if command -v jq >/dev/null 2>&1; then
  if [ -n "${requested_project}" ]; then
    # Find a project by configured id or by its root folder basename.
    project_json="$(jq -rc --arg id "${requested_project}" '
      .projects
      | to_entries
      | map(select(.value.id == $id or (.key | split("/") | last) == $id))
      | first
      | if . == null then empty else (.value + {"root": .key}) end
    ' "${config_file}")"
  else
    project_json="$(jq -rc --arg root "${SERVER_ROOT}" '
      .projects[$root]
      | if . == null then empty else (. + {"root": $root}) end
    ' "${config_file}")"
  fi
fi

project_root=""
project_slug=""
project_id=""
project_name=""
domain=""
php=""
database=""

if [ -n "${project_json}" ]; then
  project_root="$(jq -r '.root // empty' <<< "${project_json}")"
  project_id="$(jq -r '.id // empty' <<< "${project_json}")"
  project_name="$(jq -r '.name // empty' <<< "${project_json}")"
  domain="$(jq -r '.domain // empty' <<< "${project_json}")"
  php="$(jq -r '.php // empty' <<< "${project_json}")"
  database="$(jq -r '.database // empty' <<< "${project_json}")"
fi

if [ -n "${project_root}" ]; then
  SERVER_ROOT="${project_root}"
fi

if [ -f "${SERVER_ROOT}/.env" ]; then
  source "${SERVER_ROOT}/.env"
fi

if [ -n "${project_root}" ]; then
  project_slug="$(basename "${project_root}")"
fi

if [ -z "${project_id}" ] && [ -n "${requested_project}" ]; then
  project_id="${requested_project}"
fi

if [ -z "${project_id}" ] && [ -n "${project_slug}" ]; then
  project_id="${project_slug}"
fi

project_dir=""
if [ -n "${project_id}" ] && [ -d "${projects_dir}/${project_id}" ]; then
  project_dir="${projects_dir}/${project_id}"
elif [ -n "${project_slug}" ] && [ -d "${projects_dir}/${project_slug}" ]; then
  project_dir="${projects_dir}/${project_slug}"
elif [ -n "${project_id}" ]; then
  project_dir="${projects_dir}/${project_id}"
fi

if [ -n "${project_dir}" ] && [ -f "${project_dir}/.env" ]; then
  source "${project_dir}/.env"
fi

if [ -n "${SERVER_ROOT}" ]; then
  SERVER_ROOT="${SERVER_ROOT/#\~/$HOME}"
fi

if [ -z "${project_name}" ] && [ -n "${APP_NAME}" ]; then
  project_name="${APP_NAME}"
fi

if [ -z "${project_name}" ] && [ -n "${project_id}" ]; then
  project_name="${project_id}"
fi

if [ -z "${project_id}" ] && [ -n "${project_name}" ]; then
  project_id="$(slugify "${project_name}")"
fi

if [ -z "${DB_DATABASE}" ] && [ -n "${database}" ]; then
  DB_DATABASE="${database}"
fi

if [ -z "${database}" ] && [ -n "${DB_DATABASE}" ]; then
  database="${DB_DATABASE}"
fi

compose_file="${project_dir}/compose.yaml"
if [ -f "${compose_file}" ]; then
  command="docker compose -f ${compose_file}"
else
  command="docker compose"
fi

if [ -n "${domain}" ] && command -v getent >/dev/null 2>&1; then
  if ! getent hosts "${domain}" 2>/dev/null | awk '{print $1}' | grep -qx '127.0.0.1'; then
    echo.warning "Domain ${domain} does not resolve to 127.0.0.1. Add it to /etc/hosts if needed."
  fi
fi
