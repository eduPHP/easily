source "${HOME}/.config/easily/.env"

function easily.new_create() {
  local project_id="${1:-}"

  if [ -z "${project_id}" ]; then
    project_id="$(basename "$(pwd)")"
  fi

  easily create "${project_id}"
}

easily.new_create "$2"
