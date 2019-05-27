UBUNTU 18.04 PROVISION
=========

1. Creating an AMI
------------

* Launch an Ubuntu 18.04 EC2 Instance.
* Connect using ssh an run:

```console
wget https://raw.githubusercontent.com/dvillarraga/aws-ec2-php-apache-provision/master/src/ubuntu-1804/ami-provision.sh -O /tmp/ami-provision.sh
sudo chmod +x /tmp/ami-provision.sh
/tmp/ami-provision.sh install aws-codedeploy-us-west-2
sudo rm /tmp/ami-provision.sh

```
**Please check and change the aws region you are using**

* Create an AMI based on this Instance.



2. Setting User Data
------------

* On future EC2 Instances, please add in the [User-Data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html): 

```console
#!/bin/bash

set -e -u
sudo apt-get -y update
sudo apt-get install -y awscli
wget https://raw.githubusercontent.com/dvillarraga/aws-ec2-php-apache-provision/master/src/ubuntu-1804/user-data.sh -O /tmp/user-data.sh
sudo chmod +x /tmp/user-data.sh
/tmp/user-data.sh install DOMAIN_NAME
sudo rm -f /tmp/user-data.sh

```
**Please set your DOMAIN_NAME**
