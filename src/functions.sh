# helpful constants and functions which can be used throughout main scripts

#### CONSTANTS ####

# colors
BLUE="\033[0;34m"
GREEN="\033[0;32m"
RED="\033[0;31m"
PURPLE="\033[0;35m"
NC="\033[0m"

#### HELPERS ####

heading () {
  case $2 in
    1)
      COLOR=$BLUE
      INDENT="#### 🟦 "
      ;;
    2)
      COLOR=$GREEN
      INDENT="## 🟢 "
      ;;
    *)
      COLOR=$RED
      INDENT="# 🔻 "
      ;;
  esac
  echo -e $COLOR$INDENT$1$NC
}
