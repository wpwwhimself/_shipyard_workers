#### INCLUDES ####

source "$(dirname "$0")/src/functions.sh"

#### SETUP ####


#### ARGUMENTS ####

usage () {
  echo "Script integrating Shipyard to a Laravel project"
  echo "Run from project directory"
  echo "-----------------"
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  -h           Show this message"
}

path_to_directory=$(cwd)

while getopts ":h" opt; do
  case $opt in
    h)
      usage
      exit 0
      ;;
    :)
      heading "🚨 Option $OPTARG requires an argument"
      usage
      exit 1
      ;;
  esac
done

#### FUNCTIONS ####


#### START ####

heading "⚓ Installing Shipyard..." 1

if [ -f "I_USE_SHIPYARD.md" ]; then
  heading "🚨 Shipyard already installed" 2
  exit 1
fi

git remote add shipyard https://github.com/wpwwhimself/shipyard.git -f

original_branch=$(git branch --show-current)
branches=()
eval "$(git for-each-ref --shell --format='branches+=(%(refname:short))' refs/heads/)"

for branch in "${branches[@]}"; do
  git checkout $branch
  git merge shipyard/main --allow-unrelated-histories -m "⚓⬆️ Shipyard updated"
  git push
done

git checkout $original_branch

####

heading "✅ All done!" 1
