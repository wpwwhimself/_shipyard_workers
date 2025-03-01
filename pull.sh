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
  echo "  -h, --help          Show this message"
  echo "      --php=<path>    Path to PHP executable"
}

if [ -z "$1" ] || [ ! -d "$1" ]; then
  heading "🚨 Directory not specified"
  usage
  exit 1
fi

while [ $# -gt 1 ]; do
  case $2 in
    -h | --help)
      usage
      exit 0
      ;;
    --php*)
      if ! has_argument $@; then
        heading "🚨 PHP path not specified"
        usage
        exit 1
      fi

      PHP=$(extract_argument $@)
      COMPOSER=$(which composer)
      shift
      ;;
    *)
      heading "🚨 Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
  shift
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

update "$1"

if [ $? -ne 0 ]; then
  traverse "$1"
fi

####

heading "🔧 Ensuring scripts are still able to run..."
find "$1" -name "*.sh" -exec chmod +x {} \;

heading "✅ All done!"
