# helper functions used throughout the scripts

heading () {
  echo -e "\033[1m---=== $1 ===---\033[0m"
}

has_argument () {
    [[ ("$1" == *=* && -n ${1#*=}) || ( ! -z "$2" && "$2" != -*)  ]];
}

extract_argument () {
  echo "${2:-${1#*=}}"
}
