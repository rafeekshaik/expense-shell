#!/bin/bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
LOG_FOLDER="/var/log/expense-log"
LOG_FILE=$(echo $0 | cut -d "." -f1 )
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOG_FOLDER/$LOG_FILE-$TIMESTAMP.log"



VALIDATE(){

    if [ $1 -ne 0 ]
then 
echo -e "$2 ......$R failure"
exit 1
else
echo -e "$2......$G success"
fi
}

CHECK_ROOT(){

if [ $USERID -ne 0 ]
then 
echo "ERROR::user must have previlleged admin access"
exit 1
fi
}

echo "script executed at :: $TIMESTAMP"
CHECK_ROOT

dnf install mysql-server -y &>>$LOG_FILE_NAME
VALIDATE $? "installing mysql server"

systemctl enable mysqld &>>$LOG_FILE_NAME
VALIDATE $? "enabling mysql server"

systemctl start mysqld &>>$LOG_FILE_NAME
VALIDATE $? "starting mysql server"

mysql -h mysql.daws17s.online -u root -pExpenseApp@1 -e 'show databases;'
if [$? -ne 0]
then

mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_FILE_NAME
VALIDATE $? "setting up the root password"

else
echo "mysql root password all ready set up skipping"
fi