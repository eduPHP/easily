source "${HOME}/.config/easily/.env"
function easily.db() {
    case "$1" in
    "backup")
        easily.db.backup
        return 0
        ;;
    "restore")
        easily.db.restore
        return 0
        ;;
    "init")
        easily.db.init
        return 0
        ;;
    *)
        echo.danger "usage: easily db restore|backup|init"
        easily help
        return 0
        ;;
    esac
}
function easily.db.init() {
  source "${EASILY_ROOT}/scripts/easily/definitions.sh" || return 0
  mysql_runtime="${EASILY_ROOT}/bin/mysql"
  echo.info "recreating $DB_DATABASE"
  scripts_folder="${project_dir}/database"
  config="$scripts_folder/config.cnf"
  if [ ! -f $config ]; then
      mkdir -p "$scripts_folder/data"
      echo "[client]\n user = \"${DB_USERNAME}\"\n password = \"${DB_PASSWORD}\"\n host = \"${DB_HOST}\"\n" > "$scripts_folder/config.cnf"
  fi
  $mysql_runtime --defaults-file=$config < ${EASILY_ROOT}/stubs/global.sql
  $mysql_runtime --defaults-file=$config -e "CREATE DATABASE IF NOT EXISTS ${DB_DATABASE};"
  $mysql_runtime --defaults-file=$config -e "CREATE DATABASE IF NOT EXISTS ${DB_DATABASE}_testing;"
}
function easily.db.restore() {
  source "${EASILY_ROOT}/scripts/easily/definitions.sh" || return 0
  mysql_runtime="${EASILY_ROOT}/bin/mysql"
  scripts_folder="${project_dir}/database"
  config="$scripts_folder/config.cnf"
  echo.info "resetting $DB_DATABASE"

  echo.info "restoring $DB_DATABASE backup"
  $mysql_runtime --defaults-file=$config -e "DROP DATABASE IF EXISTS $DB_DATABASE;"
  $mysql_runtime --defaults-file=$config -e "CREATE DATABASE IF NOT EXISTS ${DB_DATABASE};"
  $mysql_runtime --defaults-file=$config -e "CREATE DATABASE IF NOT EXISTS ${DB_DATABASE}_testing;"
  for filename in $scripts_folder/*-latest.sql; do
      echo.info "running $(basename ${filename})"
      $mysql_runtime --defaults-file=$config $DB_DATABASE < "$filename"
  done
  art migrate
  echo.success "restored"
}
function easily.db.backup() {
  source "${EASILY_ROOT}/scripts/easily/definitions.sh" || return 0
  source "${project_dir}/.env"
  echo.info "backing up database $DB_DATABASE"
  mysqldump_runtime="${EASILY_ROOT}/bin/mysqldump"
  scripts_folder="${project_dir}/database"
  config="$scripts_folder/config.cnf"
  backupFileName="$scripts_folder/01-backup-${project_id}-latest.sql"
  if [ -f $backupFileName ]; then
    date=$(date -r $backupFileName '+%Y%m%d%H%M%S')
    newName="01-backup-${project_id}-${date}.sql"
    echo.info "moving latest backup to $newName"
    mv $backupFileName "$scripts_folder/$newName"
  fi
  $mysqldump_runtime --defaults-file=$config $DB_DATABASE --result-file=$backupFileName --skip-add-locks --add-drop-table
  echo.success "backup complete on file $(basename ${backupFileName})"
}
easily.db $2
