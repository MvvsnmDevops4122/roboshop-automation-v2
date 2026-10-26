#!/bin/bash


source ./common.sh

check_root

# Add the RabbitMQ repository to the system and install the RabbitMQ server package
cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
validate $? "Adding RabbitMQ repo"

# Install Erlang and RabbitMQ server packages
dnf install erlang rabbitmq-server -y &>> $logs_file
validate $? "Installing RabbitMQ server"

# Enable and start the RabbitMQ service
systemctl enable rabbitmq-server &>> $logs_file
systemctl start rabbitmq-server &>> $logs_file
validate $? "Starting and Enabling RabbitMQ Server"

# Verify if the user already exist or not. If not then create the user.
rabbitmqctl list_users | grep -qw "roboshop"  #get the command from google
if [ $? -ne 0 ]; then
    rabbitmqctl add_user roboshop roboshop123 &>> $logs_file
    validate $? "Creating RabbitMQ user for Roboshop"    
else
    echo -e "$(timestamp) [INFO] RabbitMQ user already exist...${Y}SKIPPING${N}" 
fi

# Set the permissions for the user to access the RabbitMQ server.
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $logs_file
validate $? "Setting permissions for RabbitMQ user for Roboshop"

total_time