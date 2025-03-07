#### INCLUDES ####

source "$(dirname "$0")/src/functions.sh"

#### SETUP ####

PHP=php

#### ARGUMENTS ####

usage () {
  echo "Script for running Laravel scheduler"
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

#### START ####

heading "🏃 Running workers..."

cd $path_to_directory

$PHP artisan schedule:run >> /dev/null 2>&1

heading "✅ All done!"
