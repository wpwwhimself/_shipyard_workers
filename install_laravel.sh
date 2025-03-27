#### INCLUDES ####

source "$(dirname "$0")/src/functions.sh"

#### SETUP ####

PHP=php
COMPOSER=composer

#### ARGUMENTS ####

usage () {
  echo "Script for installing Laravel application cloned from git"
  echo "Run from project directory"
  echo "-----------------"
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  -h           Show this message"
  echo "  -p <path>    Path to PHP executable"
}

while getopts ":hp:" opt; do
  case $opt in
    h)
      usage
      exit 0
      ;;
    p)
      PHP=$OPTARG
      COMPOSER=$(which composer)
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

heading "🔨 Configuring repository..."

cp .env.example .env

sed -i 's/APP_ENV=local/APP_ENV=stage/' .env
sed -i 's/APP_LOCALE=en/APP_LOCALE=pl/' .env

read -p "Enter database name: " DBNAME
sed -i "s/DB_DATABASE=.*/DB_DATABASE=${DBNAME}/" .env
read -p "Enter database name: " DBNAME
sed -i "s/DB_USERNAME=.*/DB_USERNAME=daemon/" .env
sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=7DmHdDctBI6?/" .env

$PHP $COMPOSER install
$PHP artisan key:generate
$PHP artisan migrate --seed

$PHP artisan storage:link

find . -type f -exec chmod 644 {} \;
find . -type d -exec chmod 755 {} \;
chgrp -R www-data storage bootstrap/cache
chmod -R ug+rwx storage bootstrap/cache

################

heading "⛓️‍💥 Configuring links..."

read -p "Enter link path: /var/www/" PATH 
ln -s public /var/www/${PATH}

################

heading "🚀 Deployment complete!"
