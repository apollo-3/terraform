LINK="https://packages.chef.io/files/stable/chef-server/12.17.15/el/7/chef-server-core-12.17.15-1.el7.x86_64.rpm"
WORK_DIR="/tmp"
cd $WORK_DIR

USER="admin"
USER_NAME="Allen"
USER_SURNAME="Iverson"
USER_EMAIL="test@test.com"
USER_KEY="/root/admin.pem"
PASSWORD="admin1"

ORG="myorg"
ORG_NAME="My Organization"
VALIDATE_KEY="/root/validator.pem"

yum install wget -y
wget "$LINK" -O "$WORK_DIR/chef.rpm"
rpm -Uvh "$WORK_DIR/chef.rpm"
chef-server-ctl reconfigure
chef-server-ctl user-create $USER $USER_NAME $USER_SURNAME $USER_EMAIL $PASSWORD --filename $USER_KEY
chef-server-ctl org-create $ORG "$ORG_NAME" --association_user $USER --filename $VALIDATE_KEY