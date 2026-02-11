source "${HOME}/.config/easily/.env"
function easily.db() {
    local action="$1"
    local requested_project="$2"

    case "${action}" in
    "backup")
        easily.db.backup "${requested_project}"
        return $?
        ;;
    "restore")
        easily.db.restore "${requested_project}"
        return $?
        ;;
    "init")
        easily.db.init "${requested_project}"
        return $?
        ;;
    "start")
        docker compose -f "${EASILY_ROOT}/config/compose.yaml" -p easily up -d mysql
        return $?
        ;;
    "stop")
        docker compose -f "${EASILY_ROOT}/config/compose.yaml" -p easily stop mysql
        return $?
        ;;
    *)
        echo.danger "usage: easily db restore|backup|init [project]"
        easily help
        return 1
        ;;
    esac
}
function easily.db.init() {
  local requested_project="${1:-}"
  source "${EASILY_ROOT}/scripts/easily/definitions.sh" "${requested_project}" || return 1

  local mysql_runtime="${EASILY_ROOT}/bin/mysql"
  local scripts_folder="${project_dir}/database"
  local config="${scripts_folder}/config.cnf"
  local db_name="${DB_DATABASE:-$database}"
  local db_user="${DB_USERNAME:-root}"
  local db_password="${DB_PASSWORD:-secret}"
  local db_host="${DB_HOST:-localhost}"

  if [ -z "${db_name}" ]; then
    echo.danger "Unable to resolve DB_DATABASE for project ${project_id}."
    return 1
  fi

  mkdir -p "${scripts_folder}/data"

  if [ ! -f "${config}" ]; then
    cat > "${config}" << EOF
[client]
user = "${db_user}"
password = "${db_password}"
host = "${db_host}"
EOF
  fi

  echo.info "recreating ${db_name}"
  "${mysql_runtime}" --defaults-file="${config}" < "${EASILY_ROOT}/stubs/global.sql" || return 1
  "${mysql_runtime}" --defaults-file="${config}" -e "CREATE DATABASE IF NOT EXISTS ${db_name};" || return 1
  "${mysql_runtime}" --defaults-file="${config}" -e "CREATE DATABASE IF NOT EXISTS ${db_name}_testing;" || return 1
}
function easily.db.restore() {
  local requested_project="${1:-}"
  source "${EASILY_ROOT}/scripts/easily/definitions.sh" "${requested_project}" || return 1

  local mysql_runtime="${EASILY_ROOT}/bin/mysql"
  local scripts_folder="${project_dir}/database"
  local config="${scripts_folder}/config.cnf"
  local db_name="${DB_DATABASE:-$database}"
  local latest_files=()

  if [ ! -f "${config}" ]; then
    easily.db.init "${requested_project}" || return 1
  fi

  echo.info "resetting ${db_name}"
  echo.info "restoring ${db_name} backup"
  "${mysql_runtime}" --defaults-file="${config}" -e "DROP DATABASE IF EXISTS ${db_name};" || return 1
  "${mysql_runtime}" --defaults-file="${config}" -e "CREATE DATABASE IF NOT EXISTS ${db_name};" || return 1
  "${mysql_runtime}" --defaults-file="${config}" -e "CREATE DATABASE IF NOT EXISTS ${db_name}_testing;" || return 1

  shopt -s nullglob
  latest_files=("${scripts_folder}"/*-latest.sql)
  shopt -u nullglob

  if [ "${#latest_files[@]}" -eq 0 ]; then
      echo.warning "No *-latest.sql backup files found in ${scripts_folder}."
      return 1
  fi

  for filename in "${latest_files[@]}"; do
      echo.info "running $(basename "${filename}")"
      "${mysql_runtime}" --defaults-file="${config}" "${db_name}" < "${filename}" || return 1
  done

  if command -v art >/dev/null 2>&1; then
    art migrate
  fi

  echo.success "restored"
}
function easily.db.backup() {
  local requested_project="${1:-}"
  source "${EASILY_ROOT}/scripts/easily/definitions.sh" "${requested_project}" || return 1

  local db_name="${DB_DATABASE:-$database}"
  local mysqldump_runtime="${EASILY_ROOT}/bin/mysqldump"
  local scripts_folder="${project_dir}/database"
  local config="${scripts_folder}/config.cnf"
  local backupFileName
  local date
  local newName

  if [ -z "${db_name}" ]; then
    echo.danger "Unable to resolve DB_DATABASE for project ${project_id}."
    return 1
  fi

  if [ ! -f "${config}" ]; then
    easily.db.init "${requested_project}" || return 1
  fi

  echo.info "backing up database ${db_name}"
  backupFileName="${scripts_folder}/01-backup-${project_id}-latest.sql"

  if [ -f "${backupFileName}" ]; then
    date="$(date -r "${backupFileName}" '+%Y%m%d%H%M%S')"
    newName="01-backup-${project_id}-${date}.sql"
    echo.info "moving latest backup to ${newName}"
    mv "${backupFileName}" "${scripts_folder}/${newName}" || return 1
  fi

  "${mysqldump_runtime}" \
    --defaults-file="${config}" \
    "${db_name}" \
    --result-file="${backupFileName}" \
    --skip-add-locks \
    --add-drop-table || return 1

  echo.success "backup complete on file $(basename "${backupFileName}")"
}
easily.db "$2" "$3"
