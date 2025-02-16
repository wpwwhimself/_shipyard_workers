# Script for pulling and updating all projects
# Run from anywhere

#### INCLUDES ####

source "$(dirname "$0")/src/functions.sh"

#### ARGUMENTS ####

if [ -z "$1" ] || [ ! -d "$1" ]; then
    echo "Usage: $0 <path_to_directory>"
    exit 1
fi

#### FUNCTIONS ####

update() {
  local folder=$1

  cd "$folder"

  if [ -d "$folder/.git" ]; then
    git pull

    if [ -e "composer.json" ]; then
      composer update
      php artisan optimize:clear
      php artisan migrate --force
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
traverse "$1"

####

heading "🔧 Ensuring Shipyard Workers are still able to run..."
find "$1/_shipyard_workers" -name "*.sh" -exec chmod +x {} \;

heading "✅ All done!"
