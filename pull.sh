#### INCLUDES ####

source "$(dirname "$0")/src/functions.sh"

#### SETUP ####

PHP=php
COMPOSER=$(which composer)
INSTALL_ANYWAY=0

#### ARGUMENTS ####

usage () {
  echo "Script for pulling and updating all projects"
  echo "Run from anywhere"
  echo "-----------------"
  echo "Usage: $0 <path_to_directory> [OPTIONS]"
  echo "Options:"
  echo "  -h           Show this message"
  echo "  -p <path>    Path to PHP executable"
  echo "  -c <path>    Path to Composer executable"
  echo "  -f           Force reinstallation of dependencies (normally skipped if repo is up to date)"
}

if [ -z "$1" ] || [ ! -d "$1" ]; then
  heading "🚨 Directory not specified"
  usage
  exit 1
fi

path_to_directory=$(readlink -m "$1")
shift

while getopts ":hp:f" opt; do
  case $opt in
    h)
      usage
      exit 0
      ;;
    p)
      PHP=$OPTARG
      ;;
    c)
      COMPOSER=$OPTARG
      ;;
    f)
      INSTALL_ANYWAY=1
      ;;
    \?)
      heading "🚨 Unknown argument: $1"
      usage
      exit 1
      ;;
    :)
      heading "🚨 Option $OPTARG requires an argument"
      usage
      exit 1
      ;;
  esac
done

#### FUNCTIONS ####
#
update() {
  local folder=$1

  cd "$folder"

  if [ -d "$folder/.git" ]; then
    local git_output
    local pull_status
    git_output=$(git pull)
    pull_status=$?
    if [ $pull_status -ne 0 ]; then
      git reset --hard
      git_output=$(git pull)
      pull_status=$?
    fi

    # if repo is up to date, don't do anything
    if [ "$INSTALL_ANYWAY" -eq 0 ] && echo "$git_output" | grep -q "Already up to date"; then
      return 0
    fi

    if [ -e "composer.json" ]; then
      $PHP $COMPOSER update
      chmod -R ug+rwx storage bootstrap/cache # ensure permissions for cache:clear
      $PHP artisan optimize:clear
      $PHP artisan migrate --force
    fi

    if [ -e "package.json" ]; then
      npm install
      npm run build
    fi

    return 0
  fi

  return 1
}

traverse() {
  local parent_dir="$1"

  # Loop through all items in the directory
  for folder in "$parent_dir"/*; do
    if [ -d "$folder" ]; then
      cd "$folder"
      heading "🔨 Entering directory: $(pwd)"
      
      update .

      if [ $? -ne 0 ]; then
        traverse .
      fi

      cd ..
    fi
  done
}

#### START ####

heading "🍃 Pulling..."

update $path_to_directory

if [ $? -ne 0 ]; then
  traverse $path_to_directory
fi

####

heading "✅ All done!"
