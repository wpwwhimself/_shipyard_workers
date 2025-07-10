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

heading "🩺 Checking apps..." 1

heading "Total space available" 2
df -h / $1
df -ih / $1
du -sh / $1
quota -s

heading "DB size" 2
echo "-- omitted --" #todo uzupełnić

heading "Catalog size" 2
du -achS $1 | sort -hr | head -n 10

heading "Backups size" 2
find $1 -name "*backup*" -exec du -sh {} \; | sort -hr | head -n 10

heading "Journal size" 2
du -sh /var/log/journal

heading "Temporary files" 2
du -achS ~/tmp
