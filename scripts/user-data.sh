#!/bin/bash
yum update -y
cd /home/ec2-user/crud-mysql
node app.js &
