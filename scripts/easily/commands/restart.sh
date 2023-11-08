#!/usr/bin/bash

EASILY_ROOT="${HOME}/code/docker"

function easily.restart() {
  local LOCK="${EASILY_ROOT}/.easily.running.lock"

  if [ $# -eq 0 ]; then
      if [ ! -f $LOCK ]; then
        echo.danger "No arguments supplied or no project running"
        easily help
        return 0
      else
        source $LOCK
        set -- $EASILY_RUNNING
      fi
  fi

  easily stop $1
  easily start $1
}

easily.restart $2