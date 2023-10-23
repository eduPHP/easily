function echo.info() {
    echo -e "\033[0;34m$1\e[0m"
}
function echo.success() {
    echo -e "\033[0;32m🟢 $1\e[0m"
}
function echo.warning() {
    echo -e "\033[0;33m🟢 $1\e[0m"
}
function echo.danger() {
    echo -e "\033[0;31m🟥 $1\e[0m"
}