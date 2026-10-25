#!/bin/bash

source ./common.sh
check_root
# copy the mongo repo file to /etc/yum.repos.d/
cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $logs_file
validate $? "Adding MongoDB repo"

# install the mongodb-org package
dnf install mongodb-org -y &>> $logs_file
validate $? "MongoDB installation"

# enable and start the mongodb service
systemctl enable mongod &>> $logs_file
systemctl start mongod &>> $logs_file
validate $? "Enable and start Mongodb"

# update the mongodb config file to allow remote connections
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
validate $? "Updating remote connections to MongoDB"

# restart the mongodb service to apply the changes
systemctl restart mongod
validate $? "Restarting MongoDB"

total_time

