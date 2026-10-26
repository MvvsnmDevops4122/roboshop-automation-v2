#!/bin/bash

app_name=shipping
source ./common.sh
check_root

app_setup
java_setup


# Install MySQL client to connect to the MySQL database server. This is required for the shipping application to interact with the database.
dnf install mysql -y &>> $logs_file
validate $? "Installing MySQL client"

count=$(mysql -h "mysql.$domain_name" -u root -pRoboShop@1 -N -B -e "SELECT COUNT(*) FROM cities.cities;" 2>> $logs_file )
if [ -z "$count" ] || [ "$count" -eq 0 ]; then
    mysql -h "mysql.$domain_name" -uroot -pRoboShop@1 < /app/db/master-data.sql
    validate $? "Loading shipping data"
else
    echo -e "$(timestamp) [INFO] Master data already loaded...${Y}SKIPPING${N}"
fi

mysql -h "mysql.$domain_name" -uroot -pRoboShop@1 < /app/db/app-user.sql
validate $? "Creating APP user"

systemd_setup

restart
total_time
