find . -type f -exec chmod 644 {} \;
find . -type d -exec chmod 755 {} \;
chgrp -R www-data storage bootstrap/cache public database
chmod -R ug+rwx storage bootstrap/cache public database
