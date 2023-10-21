EASILY_ROOT="${HOME}/code/docker"

function easilyRemove() {
  if [ $# -eq 0 ]
    then
      echo "No arguments supplied"
      easily help
      return 0
  fi

  source "${EASILY_ROOT}/scripts/easily/definitions.sh" || return 0
  echo -e "\033[0;33m Removing ${project_name}"

  # TODO: Ask for confirmation

  eval "${command} -p ${project_alias} rm -fsv"
  rm -rf "${EASILY_ROOT}/projects/${project_id}"

#  clear
  echo -e "\033[0;33m Removed ${project_name}"
}

easilyRemove $2