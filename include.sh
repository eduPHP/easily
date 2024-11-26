easilyENV="${HOME}/.config/easily/.env"
if [ ! -f "$easilyENV" ]; then
    mkdir -p "${HOME}/.config/easily"
    touch $easilyENV
fi
selfArg="$BASH_SOURCE"
if [ -z "$selfArg" ]; then
    selfArg="$0"
fi

self=$(realpath $selfArg 2> /dev/null)
if [ -z "$self" ]; then
    self="$selfArg"
fi

EASILY_ROOT=$(cd "${self%[/\\]*}" > /dev/null; pwd)

echo "EASILY_ROOT=${EASILY_ROOT}" > $easilyENV
source $easilyENV

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
#alias e="bash -c 'source ${EASILY_ROOT%,}/include.sh && easily' $@"
# need to `sudo apt install jq`
alias e=easily
