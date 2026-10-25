#!/bin/bash

user_id=$(id -u)
logs_folder="/var/log/roboshop"
logs_file="${logs_folder}/${0}.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

# check if the script is run as sudo or not. if not then exit the script with error message

check_root (){
    if [ $user_id -ne 0 ]; then
        echo "Please run this script with sudo access.."
        exit 1
    fi
}

# create the logs folder if not exists
mkdir -p $logs_folder

timestamp(){
    date "+%F %T"
}

# start the script execution 
echo -e "$(timestamp) [INFO] ==== Script started Execution =====" | tee -a $logs_file

# validate function to check the exit status of the command 
validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$(timestamp) [ERROR] ${2}..${R}FAILED${N}" | tee -a $logs_file
        exit 1
    else
        echo -e "$(timestamp) [INFO] ${2}..${G}SUCCESS${N}" | tee -a $logs_file
    fi
}

nodejs_setup(){
    dnf module disable nodejs -y &>> $logs_file
    dnf module enable nodejs:24 -y &>> $logs_file
    dnf install nodejs -y &>> $logs_file
    validate $? "Installing NodeJS"

    npm install &>> $logs_file
    validate $? "Installing nodejs dependencies for catalogue application"
}

app_setup(){
    id roboshop &>> $logs_file
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $logs_file
        validate $? "Creating system user"
    else
        echo -e "$(timestamp) [INFO] System user roboshop already exist...${Y}SKIPPING${N}"
    fi

    rm -rf /app
    validate $? "Removing old code"

    mkdir -p /app
    validate $? "Creating app directory"

    curl -L -o "/tmp/$app_name.zip" "https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/$app_name-v4.zip" &>> $logs_file
    validate $? "Downloading $app_name"

    cd /app
    unzip "/tmp/$app_name.zip" &>> $logs_file
    validate $? "Unzipping $app_name"
}

systemd_setup(){
    sed -i "s/DOMAIN_NAME/$domain_name/g" "$scripts_dir/$app_name.service"
    cp "$scripts_dir/$app_name.service" /etc/systemd/system/$app_name.service

    systemctl daemon-reload &>> $logs_file
    systemctl enable $app_name &>> $logs_file
    systemctl start $app_name &>> $logs_file
    validate $? "Starting and enabling $app_name"
}

restart(){
systemctl restart $app_namee &>> $logs_file
validate $? "Restarting $app_name service"
}

total_time (){
    echo -e "$(timestamp) [INFO] Script completed in $SECONDS seconds"  | tee -a $logs_file
    echo -e "$(timestamp) [INFO] ==== Script completed Execution =====" | tee -a $logs_file
}