# Easily Environment

Local Docker workflow for running multiple PHP projects in parallel behind a shared Caddy reverse proxy.

## Dependencies

- [docker](https://docs.docker.com/get-docker/)
- [docker-compose-v2](https://github.com/docker/compose)
- `jq` (optional, for some helper scripts)

## Setup

Add this to your shell profile (`.bashrc`, `.zshrc`, etc.):

```bash
source ~/path/to/this/project/include.sh
```

This adds the `easily` command.

## Commands

```bash
Usage: easily [start|stop|restart|create|remove|db] {project}
- start {project|all}     Starts one project or all projects
- stop {?project|all}     Stops one project, all projects, or current running project(s)
- restart {?project|all}  Restarts one project, all projects, or current running project(s)
- create {project}        Creates a new project scaffold
- remove {project}        Removes project containers and local project config
- db [backup|restore|init|start|stop] {?project}
```

## Creating a Project

```bash
easily create my-project
```

Then edit `projects/my-project/.env` with your project details.

## Parallel Project Routing

- A single shared Caddy container listens on host ports `80` and `443`.
- If `80/443` are already in use, startup falls back to `8080/8443`.
- Each project runs its own internal `app` (Caddy) + `php` containers.
- `easily start <project>` registers `https://<project-domain>` route automatically.
- `easily start all` starts every project under `projects/`.

## Aliases

| Alias | Description |
|---|---|
| `rebuild {service}` | Rebuilds a given service (`app`, `php`, etc.) |

Aliases are loaded per project context and can be customized by copying `stubs/.aliases` to `projects/<project>/.aliases`.
