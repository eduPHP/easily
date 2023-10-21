EASILY_ROOT="${HOME}/code/docker"

local config=$EASILY_ROOT/config/projects.ini
local projects_dir="${EASILY_ROOT}/projects"
local project_id=$(sed -nr '/^\[aliases\]/ { :l /^\s*[^#].*/ p; n; /^\[/ q; b l; }' $config |grep "$1="| sed "s/$1=//g")

if [ -z $project_id ]; then
  local project_id=$1
fi
local project_dir="${projects_dir}/${project_id}"

if [ ! -d $project_dir ]
then
  echo "Project \"$1\" not found!"
  echo "Run \"easily create $1\" to create it!"
  easily help
  return 1
fi

local project_name=$(sed -nr '/^\[names\]/ { :l /^\s*[^#].*/ p; n; /^\[/ q; b l; }' $config |grep "$project_id="| sed "s/$project_id=//g")

if [ -z $project_name ]; then
  local project_name=$project_id
fi

local project_alias="$(echo "${project_name}" | sed 's/[- ]/_/g' | sed 's/[A-Z]/\l&/g' )"
local docker_compose="${project_dir}/docker-compose.yml"
local command="docker-compose -f $docker_compose"
