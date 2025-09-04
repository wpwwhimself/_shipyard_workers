#### INCLUDES ####

source "$(dirname "$0")/src/functions.sh"

#### SETUP ####

RUN_DF=1

#### ARGUMENTS ####

usage () {
  echo "Script for analyzing disk space used by projects"
  echo "Run from anywhere"
  echo "-----------------"
  echo "Usage: $0 <path_to_directory> [OPTIONS]"
  echo "Options:"
  echo "  -h           Show this message"
  echo "  -d           Don't run df"
}

if [ -z "$1" ] || [ ! -d "$1" ]; then
  heading "🚨 Directory not specified"
  usage
  exit 1
fi

path_to_directory=$(readlink -m "$1")
shift

while getopts ":hd" opt; do
  case $opt in
    h)
      usage
      exit 0
      ;;
    d)
      RUN_DF=0
      ;;
    :)
      heading "🚨 Option $OPTARG requires an argument"
      usage
      exit 1
      ;;
  esac
done

#### START ####

heading "🩺 Checking apps..." 1

heading "Total space available" 2

if [ $RUN_DF -eq 1 ]; then
  df -h $path_to_directory
  df -ih $path_to_directory
fi
du -sh $path_to_directory
quota -s

heading "DB size" 2
echo "-- omitted --" #todo uzupełnić

heading "Catalog size" 2
du -achd 3 $path_to_directory | sort -hr | head -n 15

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
