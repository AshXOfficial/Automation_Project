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