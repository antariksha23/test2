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




# Bookkeeping

inventory_file=/var/www/html/inventory.html
log_type="httpd-logs"
timestamp=$(stat --printf=%y /tmp/$filename | cut -d.  -f1)
file_type=${filename##*.}
size=$(ls -lh /tmp/${filename} | cut -d " " -f5)


echo "File_Name : $filename"
echo "Log_Type : $log_type"
echo "Time_Of_Creation : $timestamp"
echo "Type_Of_File : $file_type"
echo "File_Size : $size"

if  test -f "$inventory_file"
then
echo "<br>${log_type}&nbsp;&nbsp;&nbsp;&nbsp;${timestamp}&nbsp;&nbsp;&nbsp;&nbsp;${file_type}&nbsp;&nbsp;&nbsp;&nbsp;${size}">>"${inventory_file}"
echo "Inventory file updated"
else
echo "Creating '$inventory_file'"
`touch ${inventory_file}`
echo "<b>Log Type&nbsp;&nbsp;&nbsp;&nbsp;Date Created&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Type&nbsp;&nbsp;&nbsp;Size</b>">>"$$echo "<br>${log_type}&nbsp;&nbsp;&nbsp;&nbsp;${timestamp}&nbsp;&nbsp;&nbsp;&nbsp;${file_type}&nbsp;&nbsp;&nbsp;&nbsp;${size}">>"${inventory_file}"
echo "UPDATED '$inventory_file' HEADER and Data"
fi


# Cron Job

cron_file=/etc/cron.d/automation
if test -f "$cron_file"
then
echo "Cron Exists!"
else
echo "Creating Cron File $cron_file"
touch $cron_file
echo "SHELL=/bin/bash" > $cron_file
echo "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin" >> $cron_file
echo "0 2 * * * root /root/Automation_Project/automation.sh" >> $cron_file
echo "Cron file created"
fi