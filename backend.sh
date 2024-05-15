#!/bin/bash

source ./common.sh

check_root


echo "Please enter DB Password:"
read -s mysql_root_password

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling Default version of NodeJs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling NodeJs Version of 20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing NodeJs"

id expense &>>$LOG_FILE
if [ $? -ne 0 ]
then
    useradd expense &>>$LOG_FILE
    VALIDATE $? "Creating expense user"
else
    echo -e "Expense user already Created... $Y SKIPPING $N"
fi


mkdir -p /app &>>$LOG_FILE
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
VALIDATE $? "Downloading Backend Code"

cd /app
rm -rf /app/* 
unzip /tmp/backend.zip &>>$LOG_FILE
VALIDATE $? "Extracting backend Code"


npm install &>>$LOG_FILE
VALIDATE $? "Installing NPM"

cp /home/ec2-user/expenses1/backend.service  /etc/systemd/system/backend.service &>>$LOG_FILE
VALIDATE $? "copied backend service"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon Reload"
systemctl start backend &>>$LOG_FILE
VALIDATE $? "Starting backend"
systemctl enable backend &>>$LOG_FILE
VALIDATE $? "Enabling backend"

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing MySql Client"

mysql -h db.nelipudidevops.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOG_FILE
VALIDATE $? "schema loading"

systemctl restart backend &>>$LOG_FILE
VALIDATE $? "Restarting backend"






