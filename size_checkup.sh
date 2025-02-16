# Script for analyzing disk space used by projects
# Run from anywhere

#### INCLUDES ####

source "$(dirname "$0")/src/functions.sh"

#### ARGUMENTS ####

if [ -z "$1" ] || [ ! -d "$1" ]; then
    echo "Usage: $0 <path_to_directory>"
    exit 1
fi

#### START ####

heading "🩺 Checking apps..."

####

heading "💊 Total space available"

df -h /

####

heading "💊 Space taken"

du -khd 2 "$1" | sort -hr

####

heading "💊 Temporary files"

if [ -d "~/tmp" ]; then
  du ~/tmp -khs
fi
