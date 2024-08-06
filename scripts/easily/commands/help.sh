echo "Usage: easily [start|stop|create|remove|db] {project}";
echo "- start {project}\t Starts the project";
echo "- stop {?project}\t Stops the given project or the project currently running";
echo "- restart {?project}\t Restart the given project or the project currently running";
echo "- create {project}\t Creates a new project";
echo "- remove {project}\t Removes the project containers from docker";
echo "- db [backup|restore|init] {project}\t Backup or restore the project database";
echo "- help\t\t\t Shows this help message\n";