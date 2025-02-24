# Script for installing Laravel application cloned from git
# Run from project directory

#### INCLUDES ####

source "$(dirname "$0")/src/functions.sh"

#### START ####

heading "🔨 Configuring repository..."

cp .env.example .env

sed -i '' 's/APP_ENV=local/APP_ENV=stage/' .env
sed -i '' 's/APP_LOCALE=en/APP_LOCALE=pl/' .env

read -p "Enter database name: " DBNAME
sed -i '' "s/DB_DATABASE=.*/DB_DATABASE=${DBNAME}/" .env
read -p "Enter database name: " DBNAME
sed -i '' "s/DB_USERNAME=.*/DB_USERNAME=daemon/" .env
sed -i '' "s/DB_PASSWORD=.*/DB_PASSWORD=7DmHdDctBI6?/" .env

composer install
php artisan key:generate
php artisan migrate --seed

php artisan storage:link

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
