#!/bin/bash

name=Ashwin
timestamp=$(date '+%d%m%Y-%H%M%S')
s3_bucket=upgrad-ashwin

#System Package Update
echo ">>> Updating Existing Packages"
sudo apt update -y
echo ">>> Existing Packages Updated"

#Apache2 Installation
if echo dpkg --get-selections | grep -q "apache2"
then 
    echo ">>> Apache2 is already installed";
else 
    echo ">>> Apache2 Doesn't Exists, Installing Apache2. PLease Wait!";
    sudo apt install apache2
    echo ">>> Apache2 Installation Complete";
fi

#Apache2 Status Check
if systemctl is-active apache2
then
    echo ">>> Apache2 Server is Active (Running)"
else    
    echo ">>> Starting Apache2 Server"
    sudo systemctl start apache2
    echo ">>> Apache2 Server Started"
fi

#Apache2 Service Enablement
if systemctl is-enabled apache2
then
    echo ">>> Apache2 Service Already Enable";
else
    echo ">>> Apache2 Service Found Disabled, Enabling Now!";
    sudo systemctl enable apache2
    echo ">>> Apache2 Service Enabled";
fi

# Creating Archive of Apache2 Logs
echo ">>> Archiving Apache2 Log Files. Please Wait!"
sudo tar -cvf /tmp/${name}-httpd-logs-${timestamp}.tar .tar /var/log/apache2/*.log
echo ">>> Archiving of ${name}-httpd-logs-${timestamp}.tar Complete and Exists in /tmp/ folder"

# Uploading Archive to S3
echo ">>> Uploading Archive to S3 Bucket"
aws s3 cp /tmp/${name}-httpd-logs-${timestamp}.tar s3://${s3_bucket}
echo ">>> Archive Upload Complete. Please check your S3 Bucket"

# Initiliaze Inventory File Variables
inventoryFile=/var/www/html/inventory.html
logType="httpd-logs"
filename=${name}-httpd-logs-${timestamp}.tar
type=${filename##*.}
size=$(ls -lh /tmp/${filename}| cut -d " " -f5)

# Inventory.html File Existence Check
if ! test -f "$inventoryFile"; 
then
	echo ">>> Inventory File Is Missing, Creating Inventory File";
		touch ${inventoryFile}
		echo "<html>">${inventoryFile}
        echo "<b>Log Type&nbsp;&nbsp;&nbsp;&nbsp;Time Created&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Type&nbsp;&nbsp;Size</b>">${inventoryFile}
	fi
		echo "<br>${logType}&nbsp;&nbsp;&nbsp;&nbsp;${timestamp}&nbsp;&nbsp;&nbsp;&nbsp;${type}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;${size}">>${inventoryFile}
		echo "Inventory file has been updated";

# Cron Job File Existence Check
cronFile=/etc/cron.d/automation
if test -f "$cronFile"; 
then
	echo ">>> Cron Job File Available";
else
	echo ">>> Cron Job File Missing, Creating a Cron Job File";
	touch ${cronFile}
	echo '0 0 * * * root /root/Automation_Project/automation.sh'>${cronFile}
	echo ">>> Cron Job File Created";
fi