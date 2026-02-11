source "${HOME}/.config/easily/.env"
source "${EASILY_ROOT}/scripts/easily/database.sh"
function easily.create() {
  root=$(pwd)
  local result
  local result=($(easily.project.findByRoot $root))

  if [[ -z "$result" ]]; then
    echo "Not found, creating it"

    local composerFile=${root}/composer.json

    local php
    php=$(jq -r '.require.php // empty | gsub("[^0-9.]"; "") | .[:3]' "$composerFile")
    if [ -z "${php}" ]; then
      php="8.4"
    fi
    local name=$(jq -r '.name' $composerFile)
    source ${root}/.env
    local domain=$(echo $APP_URL | sed -E 's|https?://([^/]+).*|\1|')
    local slug=$(echo $domain | sed 's/\..*//')

    result=$(easily.project.create \
      --name "$name" \
      --slug "$slug" \
      --root "$root" \
      --domain "$domain" \
      --php "$php")
  fi

  # echo $result
  # now we have a json with the project information
  # check if php exists
  # create nginx config

  easily.create.nginx "$result"

  return 0

  #  if [ -z $(update-alternatives --list php | grep $php) ]; then
  #    echo "php ${php} not installed"
  #    return 1
  #  fi


  if [ $# -eq 0 ]
    then
      read -p "Input a project name [default: $name]: " name
    else
      local name=$1
  fi
  local project_dir="${EASILY_ROOT}/projects/${project_id}"
  local project_name="$(tr "[A-Z]" "[a-z]" <<< "${project_id}")"
  echo.info "Creating ${project_name}"
  local env_path="${EASILY_ROOT}/projects/${project_id}/.env"
  mkdir -p $project_dir
  touch $env_path
  if ! grep -q PHP_VERSION "$env_path"; then
    echo "PHP_VERSION=8.4" >> $env_path
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

easily.create.nginx() {
  local project=$1 # json input

  local name=$(echo $project | jq -r '.name')
  local slug=$(echo $project | jq -r '.slug')
  local root=$(echo $project | jq -r '.root')
  local domain=$(echo $project | jq -r '.domain')
  local php=$(echo $project | jq -r '.php')
  local nginx_template="${EASILY_ROOT}/stubs/nginx.conf"

  local nginx
  nginx=$(sed \
    -e "s|{EASILY_ROOT}|${EASILY_ROOT}|g" \
    -e "s|{slug}|${slug}|g" \
    -e "s|{root}|${root}|g" \
    -e "s|{domain}|${domain}|g" \
    -e "s|{php}|${php}|g" \
    "$nginx_template")

  echo $nginx >> ${EASILY_ROOT}/config/nginx/sites/${domain}.conf
}

easily.create $2
