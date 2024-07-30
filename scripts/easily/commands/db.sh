EASILY_ROOT="${HOME}/code/docker"

function easily.db() {
    local LOCK="${EASILY_ROOT}/.easily.running.lock"
    project=$2
    if [ $# -eq 1 ]; then
        if [ -f $LOCK ]; then
          source $LOCK
          project=$EASILY_RUNNING
        fi
    fi
    case "$1" in
    "backup")
        easily.db.backup $project
        return 0
        ;;
    "restore")
        easily.db.restore $project
        return 0
        ;;
    "init")
        easily.db.init $project
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
  source "${project_dir}/.env"

  echo.info "recreating $DB_DATABASE"

  scriptsFolder="${project_dir}/database"
  config="$scriptsFolder/config.cnf"

  if [ ! -f $config ]; then
      mkdir -p "$scriptsFolder/data"
      cp "${EASILY_ROOT}/stubs/db-config.cnf" "$scriptsFolder/config.cnf"
  fi

  $mysqlRuntime --defaults-file=$config -e "DROP DATABASE IF EXISTS $DB_DATABASE;"
  $mysqlRuntime --defaults-file=$config -e "CREATE DATABASE $DB_DATABASE DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT ENCRYPTION='N';"
  easily.db.restore $1
}

function easily.db.restore() {
  source "${EASILY_ROOT}/scripts/easily/definitions.sh" || return 0
  source "${project_dir}/.env"

  mysqlRuntime="${EASILY_ROOT}/bin/mysql"
  scriptsFolder="${project_dir}/database"
  config="$scriptsFolder/config.cnf"

  echo.info "resetting $DB_DATABASE"
  $mysqlRuntime --defaults-file=$config -e "DROP DATABASE $DB_DATABASE; CREATE DATABASE IF NOT EXISTS ${DB_DATABASE};"

  echo.info "restoring $DB_DATABASE backup"
  for filename in $scriptsFolder/*-latest.sql; do
      echo.info "running $(basename ${filename})"
      $mysqlRuntime --defaults-file=$config $DB_DATABASE < "$filename"
  done
  art migrate
  echo.success "restored"
}

function easily.db.backup() {
  source "${EASILY_ROOT}/scripts/easily/definitions.sh" || return 0
  source "${project_dir}/.env"

  echo.info "backing up database $DB_DATABASE"
  mysqldumpRuntime="${EASILY_ROOT}/bin/mysqldump"
  scriptsFolder="${project_dir}/database"
  config="$scriptsFolder/config.cnf"
  backupFileName="$scriptsFolder/01-backup-${project_alias}-latest.sql"
  if [ -f $backupFileName ]; then
    date=$(date -r $backupFileName '+%Y%m%d%H%M%S')
    newName="01-backup-${project_alias}-${date}.sql"
    echo.info "moving latest backup to $newName"
    mv $backupFileName "$scriptsFolder/$newName"
  fi
  $mysqldumpRuntime --defaults-file=$config $DB_DATABASE --result-file=$backupFileName --skip-add-locks --add-drop-table
  echo.success "backup complete on file $(basename ${backupFileName})"
}

easily.db $2
