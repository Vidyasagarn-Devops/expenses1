#!/bin/bash

source ./common.sh

check_root()

echo "Please enter DB Password:"
read -s mysql_root_password


dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing MySql Server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling MySql Server"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "Starting MySql Server"

#mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_FILE
#VALIDATE $? "Settingup root Password"

mysql -h db.nelipudidevops.online -uroot -p${mysql_root_password} -e 'SHOW DATABASES;' &>>$LOG_FILE

if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password}
else
    echo -e "MySql root password is already setup.... $Y SKIPPING $N"
fi



