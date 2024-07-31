EASILY_ROOT="${HOME}/code/docker"

export PATH=$EASILY_ROOT/bin:$PATH

function easily() {
  source "${EASILY_ROOT}/scripts/easily/functions.sh"

  if [ -z $1 ]; then
    local action="help";
  else
    local action=$1
  fi

  if [ -f "${EASILY_ROOT}/scripts/easily/commands/${action}.sh" ]; then
    . "${EASILY_ROOT}/scripts/easily/commands/${action}.sh"
    return 0
  fi

  echo "\"$action\" Invalid argument";
  easily help
}

alias e=easily
