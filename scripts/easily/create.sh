EASILY_ROOT="${HOME}/code/docker"

function easilyRemove() {
  if [ $# -eq 0 ]
    then
      echo -e "Please, input a project name"
      read project_id
    else
      local project_id=$1
  fi

  local project_dir="${EASILY_ROOT}/projects/${project_id}"
  local project_name="$(tr "[A-Z]" "[a-z]" <<< "${project_id}")"
  echo -e "Creating ${project_name}"

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

  cp "${EASILY_ROOT}/stubs/docker-compose.yml" "${project_dir}/docker-compose.yml"

#  clear
  echo -e "Created ${project_id}, what's next?"
  echo -e "Edit ${env_path} with the project information"
  echo -e "sudo sh -c \"echo 127.0.0.1 ${project_id}.test >> /etc/hosts\""
  echo -e "easily start ${project_id}"
}

easilyRemove $2