#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Please enter DB Password:"
read -s mysql_root_password

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2..... $R Failure $N"
        exit 1
    else
        echo -e "$2.... $G Success $N"
    fi

}


if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access"
    exit 1
else
    echo "You are super user"
fi

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



