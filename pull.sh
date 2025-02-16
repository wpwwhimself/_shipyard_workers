# Script for pulling and updating all projects
# Run from anywhere

#### INCLUDES ####

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR"/functions.sh

#### ARGUMENTS ####

if [ -z "$1" ] || [ ! -d "$1" ]; then
    echo "Usage: $0 <path_to_directory>"
    exit 1
fi

DIRECTORY=$1

#### FUNCTIONS ####

update() {
  local folder=$1

  heading "🔨 Entering directory: $folder"

  if [ -d "$dir/.git" ]; then
    git pull
  fi

  if [ -e "$dir/composer.json" ]; then
    composer update
    php artisan optimize:clear
    php artisan migrate --force
  fi

  if [ -e "$dir/package.json" ]; then
    npm install
    npm run build
  fi
}

traverse() {
  local parent_dir="$1"

  # Loop through all items in the directory
  for item in "$parent_dir"/*; do
    if [ -d "$item" ]; then
      heading "🔨 Entering directory: $folder"

      # Call update function inside the directory
      update "$item"

      # Recursively call traverse function on subdirectory
      traverse "$item"
    fi
  done
}

#### START ####

heading "🍃 Pulling..."

traverse "$DIRECTORY"

heading "✅ All done!"
