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

total_time (){
    echo -e "$(timestamp) [INFO] Script completed in $SECONDS seconds"  | tee -a $logs_file
    echo -e "$(timestamp) [INFO] ==== Script completed Execution =====" | tee -a $logs_file
}