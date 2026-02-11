echo "Usage: easily [start|stop|create|remove|db] {project}";
echo "- start {project|all}\t Starts one project or all projects";
echo "- stop {?project|all}\t Stops the given project, all projects, or the project(s) currently running";
echo "- restart {?project|all}\t Restarts one project, all projects, or the project(s) currently running";
echo "- create {project}\t Creates a new project";
echo "- remove {project}\t Removes the project containers from docker";
echo "- db [backup|restore|init] {?project}\t Backup or restore the project database";
echo "- help\t\t\t Shows this help message\n";
