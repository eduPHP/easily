source "${HOME}/.config/easily/.env"
easily.database() {
  mysql_runtime="${EASILY_ROOT}/bin/mysql"
  config="${HOME}/.config/easily/db.cnf"

  mkdir -p "$(dirname "${config}")"

  if [ ! -f "${config}" ]; then
      cat > "${config}" << EOF
[client]
user = "root"
password = "secret"
host = "localhost"
EOF
  fi

  "${mysql_runtime}" --defaults-file="${config}" < "${EASILY_ROOT}/stubs/global.sql"
}

easily.project.findByRoot() {
  easily.database
  local root="$1"
#  local query="select * from projects where root = '${root}';"
  local query="SELECT JSON_OBJECT('id', id, 'name', name, 'slug', slug, 'domain', domain, 'php', php, 'root', root, 'created_at', created_at, 'last_start_at', last_start_at) AS json_output FROM projects where root = '${root}';"


  local query_result
  query_result=$("${mysql_runtime}" --defaults-file="${config}" -D easily -B --skip-column-names -e "${query}")

  echo "${query_result}"
}

easily.project.create() {
  easily.database
  local table="easily.projects"
  local fields=()
  local values=()
  local root

  # Parse named arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --name)
        fields+=("name")
        values+=("'$2'")
        shift 2
        ;;
      --slug)
        fields+=("slug")
        values+=("'$2'")
        shift 2
        ;;
      --domain)
        fields+=("domain")
        values+=("'$2'")
        shift 2
        ;;
      --php)
        fields+=("php")
        values+=("'$2'")
        shift 2
        ;;
      --root)
        fields+=("root")
        values+=("'$2'")
        root=$2
        shift 2
        ;;
      *)
        echo "Unknown option: $1"
        return 1
        ;;
    esac
  done

  # Ensure required fields are present
  if [[ ! " ${fields[@]} " =~ "slug" || ! " ${fields[@]} " =~ "domain" || ! " ${fields[@]} " =~ "php" || ! " ${fields[@]} " =~ "root" ]]; then
    echo "Error: Required fields --slug, --domain, --php, and --root are missing."
    return 1
  fi

  # Construct the SQL query
  IFS=", "
  local query="INSERT INTO $table (${fields[*]}, created_at) VALUES (${values[*]}, '$(date "+%Y-%m-%d %H:%M:%S")');"

  # Execute the query
  $mysql_runtime --defaults-file=$config -D easily -e "$query"

  if [[ $? -eq 0 ]]; then
    echo "$(easily.project.findByRoot "${root}")"
  fi
}
