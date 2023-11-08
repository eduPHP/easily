#!/usr/bin/bash

EASILY_ROOT="${HOME}/code/docker"

local projects_dir="${EASILY_ROOT}/projects"
local config=$projects_dir/config.json
local input_name=$1
local project_id=$(jq -r --arg name "$input_name" '.aliases[$name] | select( . != null )' <<< $(cat $config))

if [ -z $project_id ]; then
  local project_id=$input_name
fi

local project_dir="${projects_dir}/${project_id}"
if [ ! -d $project_dir ]
then
  echo.danger "Project \"$input_name\" not found!"
  echo.info "Run \"easily create $input_name\" to create it!"
  easily help
  return 1
fi

local project_name=$(jq -r --arg name "$project_id" '.names[$name] | select( . != null )' <<< $(cat $config))
if [ -z $project_name ]; then
  local project_name=$input_name
fi

local domain_status=$(curl -s -o /dev/null --cacert $EASILY_ROOT/config/nginx/rootCA.pem -w "%{http_code}" https://$input_name.test)
if [ $domain_status = "000" ]; then
  echo.warning "Run the command below to get your local domain working:"
  echo.warning "sudo sh -c \"echo 127.0.0.1 ${input_name}.test >> /etc/hosts\""
fi

local project_alias="$(echo "${project_name}" | sed 's/[- ]/_/g' | sed 's/[A-Z]/\l&/g' )"
local docker_compose="${project_dir}/compose.yaml"
local command="docker compose -f $docker_compose"
