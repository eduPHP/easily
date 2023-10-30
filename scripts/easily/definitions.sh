EASILY_ROOT="${HOME}/code/docker"

function easily.generate.config() {
  local project_dir=$1
  local project_id=${project_dir##*/}
  local config="${EASILY_ROOT}/projects/${project_id}.json"

  if [ -f $config ]; then
    cat $config
    return
  fi

  local envFile="${project_dir}/.env"
  if [ ! -f $envFile ]; then
    echo.warning "Usage requires a .env file on the project directory."
    echo.warning "Project: $project_dir"

    easily help
    return 0
  fi

  local composer="${project_dir}/composer.json"
  if [ -f $composer ]; then
    # This cuts out the minor version part ie, 8.1.* becomes 8.1
    local php_version=$(awk '{print substr($0, 0, 3)}' <<< $(jq -r '.require.php' <<< $(cat $composer) | tr -dc '0-9\.'))
  else
    local php_version=8.2
  fi

  source $envFile
  APP_URL=$(echo $APP_URL | sed "s@http://@@g" | sed "s@https://@@g")

  local json="{
  \"id\": \"$project_id\",
  \"name\": \"${APP_NAME}\",
  \"project_dir\": \"${project_dir}\",
  \"domain\": \"${APP_URL}\",
  \"php\": \"${php_version}\"
}"
  echo $json > $config
  cat $config
}

local project_dir=$(pwd)
local config=$(easily.generate.config $project_dir) || return 1
local php_version=$(jq -r '.php' <<< ${config})
local project_id=$(jq -r '.id' <<< ${config})
local project_name=$(jq -r '.name' <<< ${config})
local domain=$(jq -r '.domain' <<< ${config})

local globalCompose="${EASILY_ROOT}/compose/global-compose.yaml"
local phpCompose="${EASILY_ROOT}/compose/php${php_version}-compose.yaml"
local appCompose="${EASILY_ROOT}/compose/nginx-compose.yaml"
local npmCompose="${EASILY_ROOT}/compose/npm-compose.yaml"
local command="docker compose -f $globalCompose -f $phpCompose -f $appCompose -p easily"
