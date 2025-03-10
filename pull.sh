#### INCLUDES ####

source "$(dirname "$0")/src/functions.sh"

#### SETUP ####

PHP=php
COMPOSER=composer

#### ARGUMENTS ####

usage () {
  echo "Script for pulling and updating all projects"
  echo "Run from anywhere"
  echo "-----------------"
  echo "Usage: $0 <path_to_directory> [OPTIONS]"
  echo "Options:"
  echo "  -h           Show this message"
  echo "  -p <path>    Path to PHP executable"
}

if [ -z "$1" ] || [ ! -d "$1" ]; then
  heading "🚨 Directory not specified"
  usage
  exit 1
fi

path_to_directory="$1"
shift

while getopts ":hp:" opt; do
  case $opt in
    h)
      usage
      exit 0
      ;;
    p)
      PHP=$OPTARG
      COMPOSER=$(which composer)
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

update() {
  local folder=$1

  cd "$folder"

  if [ -d "$folder/.git" ]; then
    git pull
    if [ $? -ne 0 ]; then
      git reset --hard
      git pull
    fi

    # if repo is up to date, don't do anything
    if [ "$(git rev-parse HEAD)" = "$(git rev-parse @{u})" ]; then
      return 0
    fi

    if [ -e "composer.json" ]; then
      $PHP $COMPOSER update
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

heading "🔧 Ensuring scripts are still able to run..."
find "$path_to_directory" -name "*.sh" -exec chmod +x {} \;

heading "✅ All done!"
