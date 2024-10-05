source "${HOME}/.config/easily/.env"
source "${EASILY_ROOT}/scripts/easily/database.sh"
function easily.create() {
  root=$(pwd)
  sql="select * from projects where root = '${root}';"
  mysql_runtime="${EASILY_ROOT}/bin/mysql"
  config="${HOME}/.config/easily/db.cnf"
  if [ ! -f $config ]; then
      mkdir -p "$scripts_folder/data"
      echo "[client]\n user = \"root\"\n password = \"secret\"\n host = \"localhost\"\n" > $config
  fi
  exec $mysql_runtime --defaults-file=$config < ${EASILY_ROOT}/stubs/global.sql
  data=`$mysql_runtime --defaults-file=$config easily -e "$sql"  -B --skip-column-names`
  return 1
  name=$(echo $data | awk '{print $2}')
  slug=$(echo $data | awk '{print $3}')
  domain=$(echo $data | awk '{print $4}')
  php=$(echo $data | awk '{print $5}')
  nginx=$(cat "${EASILY_ROOT}/stubs/nginx.conf")
  nginx=$(awk -v s="{EASILY_ROOT}" -v r="${EASILY_ROOT}" '{sub(s,r)}1' <<< $nginx)
  nginx=$(awk -v s="{slug}" -v r="${slug}" '{sub(s,r)}1' <<< $nginx)
  nginx=$(awk -v s="{root}" -v r="${root}" '{sub(s,r)}1' <<< $nginx)
  nginx=$(awk -v s="{domain}" -v r="${domain}" '{sub(s,r)}1' <<< $nginx)
  nginx=$(awk -v s="{php}" -v r="${php}" '{sub(s,r)}1' <<< $nginx)

#  if [ -z $(update-alternatives --list php | grep $php) ]; then
#    echo "php ${php} not installed"
#    return 1
#  fi

echo $nginx
  return 1
  if [ $# -eq 0 ]
    then
      echo -e "Please, input a project name"
      read project_id
    else
      local project_id=$1
  fi
  local project_dir="${EASILY_ROOT}/projects/${project_id}"
  local project_name="$(tr "[A-Z]" "[a-z]" <<< "${project_id}")"
  echo.info "Creating ${project_name}"
  local env_path="${EASILY_ROOT}/projects/${project_id}/.env"
  mkdir -p $project_dir
  touch $env_path
  if ! grep -q PHP_VERSION "$env_path"; then
    echo "PHP_VERSION=8.2" >> $env_path
  fi
  if ! grep -q SERVER_ROOT "$env_path"; then
    echo "SERVER_ROOT=~/code/${project_id}" >> $env_path
  fi
  if ! grep -q DB_DATABASE "$env_path"; then
    echo "DB_DATABASE=${project_id}" >> $env_path
  fi
  cp "${EASILY_ROOT}/stubs/compose.yaml" "${project_dir}/compose.yaml"
  #database
  config="$project_dir/database/config.cnf"
  if [ ! -f $config ]; then
      mkdir -p "$project_dir/database/data"
      cp "${EASILY_ROOT}/stubs/db-config.cnf" "$project_dir/database/config.cnf"
  fi
#  clear
  echo.success "Created ${project_id}, what's next?"
  echo.info "Edit ${env_path} with the project information"
  echo.info "easily start ${project_id}"
}
easily.create $2
