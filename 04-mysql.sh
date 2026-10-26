#!/bin/bash

source ./common.sh

check_root

# enable the MySQL module and install the MySQL server package
dnf module enable mysql:8.4 -y &>> $logs_file
dnf install mysql-server -y  &>> $logs_file
validate $? "Installing MySQL server"

# enable and start the MySQL service
systemctl enable mysqld  &>> $logs_file
systemctl start mysqld
validate $? "Start and Enable MySQL"

# run the MySQL secure installation command to set the root password and secure the installation
mysql_secure_installation --set-root-pass RoboShop@1  &>> $logs_file
validate $? "Setup MySQL root password"

total_time