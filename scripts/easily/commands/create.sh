EASILY_ROOT="${HOME}/code/docker"

function easily.get.volumes() {
  local VOLUMES=""

  for entry in "$EASILY_ROOT"/projects/*.json
  do
    local json=$(cat $entry)
    local id=$(jq -r '.id' <<< ${json})
    local dir=$(jq -r '.project_dir' <<< ${json})

    VOLUMES="${VOLUMES}\n      - ${dir}:/app/${id}"
  done

  echo -E $VOLUMES
}

function easily.create.php() {
  if [ $# -lt 3 ]; then
    echo.danger "Missing arguments"
    echo.danger "Usage: easily.create.php {project-dir} {project-id} {php-version}"
    return 1
  fi

  local dir=$1
  local id=$2
  local version=$3

  local composeStub=$(cat "$EASILY_ROOT/stubs/partials/php-compose.yaml.stub")
  local nginxCompose=$(echo $composeStub | sed "s@{VOLUMES}@$(easily.get.volumes)@")
  local nginxCompose=$(echo $nginxCompose | sed "s@{PHP_VERSION}@$version@")
  echo $nginxCompose > "$EASILY_ROOT/compose/php${version}-compose.yaml"
}

function easily.create.npm() {
  local npmStub=$(cat "$EASILY_ROOT/stubs/partials/npm-compose.yaml.stub")
  local npmCompose=$(echo $npmStub | sed "s@{VOLUMES}@$(easily.get.volumes)@")
  echo $npmCompose > "$EASILY_ROOT/compose/npm-compose.yaml"
}

function easily.create.certificates() {
  # Create local dertificates if it doesn't exist
  if [ ! -f "${EASILY_ROOT}/config/nginx/certs/$1.csr" ]; then
    echo.info "Certificates for '$1' doesn't exist, creating..."
    eval "sh ${EASILY_ROOT}/scripts/cert.sh $1"
  fi
}

function easily.create.siteConfig() {
  local siteStub=$(cat "$EASILY_ROOT/stubs/nginx-site.conf.stub")
  local siteConfig=$(echo $siteStub | sed "s/{DOMAIN}/$1/g")
  local siteConfig=$(echo $siteConfig | sed "s/{PROJECT_ID}/$2/g")
  local siteConfig=$(echo $siteConfig | sed "s/{PHP_VERSION}/$3/g")

  echo $siteConfig > "$EASILY_ROOT/config/nginx/sites/${domain}.conf"
}

function easily.create.nginx() {
  if [ $# -lt 3 ]; then
    echo.danger "Missing arguments"
    echo.danger "Usage: easily.create.nginx {domain} {project-id} {php-version}"
    return 1
  fi

  easily.create.certificates $@ || return 1
  easily.create.siteConfig $@ || return 1

  local composeStub=$(cat "$EASILY_ROOT/stubs/partials/nginx-compose.yaml.stub")
  local nginxCompose=$(echo $composeStub | sed "s@{VOLUMES}@$(easily.get.volumes)@")
  echo $nginxCompose > "$EASILY_ROOT/compose/nginx-compose.yaml"
}

function easily.set.aliases() {
  source $EASILY_ROOT/scripts/easily/definitions.sh || return 1
  source $EASILY_ROOT/stubs/.aliases
}

function easily.create.databases() {
  source $EASILY_ROOT/scripts/easily/definitions.sh || return 1
  local envFile="${project_dir}/.env"
  source $envFile

  eval "docker exec -t -i mysql mysql -uroot -psecret -e \"CREATE DATABASE IF NOT EXISTS ${DB_DATABASE};CREATE DATABASE IF NOT EXISTS ${DB_DATABASE}_testing;\""
}

function easily.create() {
  source "$EASILY_ROOT/scripts/easily/definitions.sh" || return 1
  easily.create.nginx $domain $project_id $php_version || return 1
  easily.create.php $project_dir $project_id $php_version || return 1
  easily.create.npm || return 1

  eval "${command} up -d"
  easily.create.databases
  easily.set.aliases
}

easily.create ${@:2}
