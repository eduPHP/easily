# Easily Environment
> Work in progres...
### Dependencies
- [docker](https://docs.docker.com/get-docker/)
- [docker-compose-v2](https://github.com/docker/compose)
How this works?
Add to your `.bashrc` or `.zshrc` or whatever:
```bash
source ~/path/to/this/project/include.sh
```
This adds the "easily" command that works like this:
```bash
Usage: easily [start|stop|create|remove] {project}
- start {project}	 Starts the project
- stop {?project}	 Stops the given project or the project currently running
- create {project}	 Creates a new project
- remove {project}	 Removes the project containers from docker
- help			 Shows this help message
```
### Creating new Projects
```bash
easily create my-project
```
### Configuration
You can call a project by a shorthand and give it a nice presentable name in the file: `./config/projects.ini`

### Aliases
| Alias                  | Description                                                                                      |
|------------------------|--------------------------------------------------------------------------------------------------|
| rebuild&nbsp;{service} | rebulds the given service, ie. `app`/`php`/`mysql` (this might delete the changes you have on it |
| npm                    | runs npm                                                                                         |
| php                    | runs php commands, ie. `php -v`                                                                  |
| p                      | runs tests `php artisan test --parallel --processes 6`                                           |
| pf {arg}               | runs tests with a filter `php artisan test --fi`                                                 |
| art                    | shorthand for `php artisan`                                                                      |
> All aliases run on the project's context
> You can customize it by copying the default aliases file to your project's directory `cp stubs/aliases.sh projects/my-project/.aliases`
### HTTPS
To run in https you need to import the certificate authority generated on `./config/nginx/rootCA.pem`
If you don't know how to do it, there are plenty of [tutorials on Google](https://www.google.com/search?channel=fs&client=ubuntu-sn&q=import+certificate+authority)

### TO-DO
- [ ] use a single nginx instance to serve the projects
- [ ] allow for multiple containers to run at the same time
- [ ] "update" command that pulls the latest changes and re-source
- [ ] a command to upgrade/downgrade php/npm versions
- [ ] a command to dump/restore the main database
- [ ] control panel
- [ ] an "install" command to install docker and all dependencies
