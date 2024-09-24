EASILY_ROOT="${HOME}/code/docker"
local SERVER_ROOT="$(pwd)"

if [ -f "${SERVER_ROOT}/.env" ]; then
  source "${SERVER_ROOT}/.env"
  local project_name=$APP_NAME
  local database=$DB_DATABASE
fi

local projects_dir="${EASILY_ROOT}/projects"
local config=$(cat $projects_dir/config.json)
local project_id=$(jq -r --arg name "$SERVER_ROOT" '.projects[$name].id | select( . != null )' <<< $config)
local domain=$(jq -r --arg name "$SERVER_ROOT" '.projects[$name].domain | select( . != null )' <<< $config)
local php=$(jq -r --arg name "$SERVER_ROOT" '.projects[$name].php | select( . != null )' <<< $config)
local project_dir="${projects_dir}/${project_id}"

if [ -z $project_name ]; then
  local project_name=$project_id
fi

if ! ping -c 1 $domain | grep '127.0.0.1' > /dev/null; then
  echo.warning "Adding to /etc/hosts, please input your root password:"
  sudo sh -c "echo 127.0.0.1 ${domain} >> /etc/hosts"
fi

local local_command=
if [ -f "${projects_dir}/${project_id}/compose.yaml" ]; then
  local local_command="docker compose -f ${projects_dir}/${project_id}/compose.yaml"
fi
