
function echo.info() {
  echo -e "\033[0;44m INFO \033[m $1"
}
function echo.success() {
  echo -e "\033[0;30;42m SUCCESS \033[m $1"
}
function echo.warning() {
  echo -e "\033[0;30;43m WARN \033[m $1"
}
function echo.danger() {
  echo -e "\033[0;41m ERROR \033[m $1"
}
