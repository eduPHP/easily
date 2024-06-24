
EASILY_ROOT="${HOME}/code/docker"

function easily.create() {
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