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
du -achd 3 $1 | sort -hr | head -n 15

heading "Backups size" 2
find . -type f -name '*backup*.zip' -printf '%h\n' \
  | sort -u \
  | while read dir; do
      count=$(find "$dir" -maxdepth 1 -type f -name '*backup*.zip' | wc -l)
      size=$(du -ch "$dir"/*backup*.zip 2>/dev/null | tail -n1 | awk '{print $1}')
      echo -e "$dir \t $count files, $size total"
    done

heading "Journal size" 2
du -sh /var/log/journal

heading "Temporary files" 2
du -sh ~/tmp
