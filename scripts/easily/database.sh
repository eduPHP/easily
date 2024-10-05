function easily.database() {
  local sql=$1
  local mysql_runtime="${EASILY_ROOT}/bin/mysql"
  local config="${HOME}/.config/easily/db.cnf"
  if [ ! -f $config ]; then
      mkdir -p "$scripts_folder/data"
      echo "[client]\n user = \"root\"\n password = \"secret\"\n host = \"localhost\"\n" > $config
  fi
  mysql_command=$mysql_runtime --defaults-file=$config < ${EASILY_ROOT}/stubs/global.sql --defaults-file=$config easily -e "$sql"  -B --skip-column-names
}