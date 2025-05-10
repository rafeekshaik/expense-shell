

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

dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "disabling existing default node js"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE $? "enabling nodejs 20"

dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "installing node js"

id expense
if [ $? -ne 0 ]
then
useradd expense &>>$LOG_FILE_NAME
VALIDATE $? "adding expense user"
else
echo "expense user allready exist.... skipping"
fi

mkdir -p /app &>>$LOG_FILE_NAME
VALIDATE $? "creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "downloading application code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOG_FILE_NAME
VALIDATE $? "unzipping the code"


cd /app
npm install &>>$LOG_FILE_NAME
VALIDATE $? "instlling dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service

dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE $? "installing mysql client"

mysql -h mysql.daws17s.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
VALIDATE $? "loading the schema into the database"

systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATE $? "demon reload hh"

systemctl enable backend &>>$LOG_FILE_NAME
VALIDATE $? "enable backend"

systemctl restart backend &>>$LOG_FILE_NAME
VALIDATE $? "restart backend"
