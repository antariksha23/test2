#!/bin/bash

name=Antariksha
service=apache2

echo "update_package:START"
sudo apt update -y
echo "Package update finished"

# Installing Apache2


service=$1
if systemctl --all --type service | grep -q "$serviceName"
then
echo "'$service'  : installed!"
else
echo "'$service'  : not installed!"
echo "Installing  : '$service'"
sudo apt install "$service" -y
echo "Installed   : '$service'"
fi



# starting service

service=$1
STATUS="$(systemctl is-active $service)"
if [ "${STATUS}" = "active" ]
then
echo "'$service': Running!"
else
echo "'$service': Starting!"
sudo apt install "$service" -y
sudo systemctl start "$service"
echo "'$service': Started!"
fi



# Enabling service

service=$1
STATUS="$(systemctl is-enabled $service)"
if [ "${STATUS}" = "enabled" ]
then
echo "$service: Already enabled!"
else
echo "$service: Enabling!"
sudo systemctl enable "$service"
fi



# log archiving

echo "Logs : Started_Archive "
timestamp=$(date '+%d%m%Y-%H%M%S')
filename="$name-httpd-logs-$timestamp.tar"
tar -cvf $filename /var/log/apache2/*.log
mv $filename /tmp/
echo "Logs : Archiving completed!"



# Copying logs to S3 Bucket

echo "Copying logs to bucket started";
bucketName=$1
aws s3 cp /tmp/$filename s3://upgrad-antariksha/$filename;



