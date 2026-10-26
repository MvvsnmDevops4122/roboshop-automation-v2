#!/bin/bash

app_name=catalogue
source ./common.sh
check_root

app_setup
nodejs_setup
systemd_setup

sed -i -e "s/DOMAIN_NAME/${domain_name}/" $scripts_dir/mongo.repo
cp $scripts_dir/mongo.repo /etc/yum.repos.d/mongo.repo &>> $logs_file
validate $? "Adding MongoDB repo"


dnf install mongodb-mongosh -y &>> $logs_file
validate $? "Installing MongoDB client"

# Check if the products collection in the catalogue database already has data. If not, load the master data into the collection using the provided master-data.js script.
product_count=$(mongosh --host mongodb.${domain_name} --quiet --eval 'db.getSiblingDB("catalogue").products.countDocuments()')
validate $? "Checking if the products collection already has data"

# If the products collection is empty, load the master data into it using the master-data.js script. Otherwise, skip this step.
if [ $product_count -eq 0 ]; then
    mongosh --host mongodb.${domain_name} </app/db/master-data.js
    validate $? "Loading master data into products collection"
else
    echo -e "$(timestamp) [INFO] Products collection already has data...${Y}SKIPPING${N}"
    
fi

restart
total_time

