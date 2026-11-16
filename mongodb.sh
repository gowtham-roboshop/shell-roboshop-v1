#!/bin/bash

user_id=$(id -u)
logs_folder="/var/log/roboshop"
logs_file="${logs_folder}/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $user_id -ne 0 ]
then
    echo "please run the script with root user"
fi

mkdir -p $logs_folder

validate(){
    if [ $1 -ne 0 ]
    then
        echo "$(timestamp) [ERROR] ${2} ...${R}FAILED${N}" | tee -a $logs_file
    else
        echo -e "$(timestamp) [INFO] ${2}..${G}SUCCESS${N}" | tee -a $logs_file
    fi

}

eecho "Script started execution at $(date +"%F %T")" &>> $logs_file

cp mongo.repo /etc/yum.repos.d/mongos.repo
validate $? "adding mongo repo"

dnf install mongodb-org -y &>> $logs_file
validate $? "install mangodb"

systemctl enable mongod &>> $logs_file
systemctl start mongod &>> $logs_file
validate $? "Enable and start MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
validate $? "Updating remote connections to MongoDB"

systemctl restart mongod
validate $? "Restarting MongoDB"
