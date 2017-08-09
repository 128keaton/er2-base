#!/bin/bash
if [ "$DB_USER" = "" ]
then
   echo "DB_USER Does not exist"
else
   ## Update DB Username
    sed -i -- 's/_user_/$DB_USER/g' /var/www/html/web/app/config/parameters.yml

    ## Update DB Name
    sed -i -- 's/_db_/$DB_NAME/g' /var/www/html/web/app/config/parameters.yml

    ## Update DB Password
    sed -i -- 's/_password_/$DB_PASSWORD/g' /var/www/html/web/app/config/parameters.yml
fi
