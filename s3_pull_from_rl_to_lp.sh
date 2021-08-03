#!/bin/bash
#
# RL to LP Sandbox Migration - Pull from S3 to LP Sandbox Web Server
# AUTHOR: Jesse Stilwell <jesse.stilwell@learningpool.com>
#
# DIRECTIONS: Run as root from LP Sandbox Web Server.
#

# Exit if we're not root
if ! [ $(id -u) = 0 ]; then
   echo "This script must be run as root!" 
   exit 1
fi

# Get variable information from user to use later
read -p "Enter RL Client Name (for LP directory name): " CLIENT_NAME
read -p "Enter Database Password (INPUT HIDDEN): " DB_PASSWORD

# Sync data from migration S3 bucket to LP Sandbox Web Server
cd /wwwsandboxusa/t2sites/uat-${CLIENT_NAME}12.sandbox.learningpool.com
mkdir sitedata_new
aws s3 sync s3://lp-rl-migration/${CLIENT_NAME}/moodledata ./sitedata_new
cd sitedata_new
rm -rf trash cache localcache lock muc sessions temp trashdir
cd ..
cp -R sitedata/maintenance sitedata_new/
cp -R sitedata/muc sitedata_new/
cp -R sitedata/saml2 sitedata_new/
chown -R www-data:www-data sitedata_new
chmod -R u+rwX,go+rX-w sitedata_new
mv sitedata sitedata_old && mv sitedata_new sitedata

# Get dashboard string prior to drop
DASHBOARD_STRING=`mysql -h totara-sandbox-usa.cbi8awzlbvzi.us-west-2.rds.amazonaws.com -u root -p${DB_PASSWORD} moodle_ta_uat_${CLIENT_NAME}12_sandbox -e "SELECT value FROM mdl_config_plugins WHERE plugin = 'auth_dashboard' AND name = 'secret_string';"`

# Prep DB for import
mysql -h totara-sandbox-usa.cbi8awzlbvzi.us-west-2.rds.amazonaws.com -u root -p${DB_PASSWORD} -e "DROP DATABASE moodle_ta_uat_${CLIENT_NAME}12_sandbox; CREATE DATABASE moodle_ta_uat_${CLIENT_NAME}12_sandbox DEFAULT CHARSET=utf8;"

# Copy MySQL dump from migration S3 bucket
cd /wwwsandboxusa/t2sites/uat-${CLIENT_NAME}12.sandbox.learningpool.com
aws s3 cp s3://lp-rl-migration/${CLIENT_NAME}/moodle.sql ./

# Import the database
pv ./moodle.sql | mysql -h totara-sandbox-usa.cbi8awzlbvzi.us-west-2.rds.amazonaws.com -u root -p${DB_PASSWORD} moodle_ta_uat_${CLIENT_NAME}12_sandbox

# Run the upgrade script
php /t12_codebase/admin/cli/upgrade_wrap.php uat-${CLIENT_NAME}12.sandbox.learningpool.com
php /t2_codebase/admin/cli/purge_wrap.php uat-${CLIENT_NAME}12.sandbox.learningpool.com

# Print Dashboard String
printf "\nOLD DASHBOARD SECRET STRING: \n$DASHBOARD_STRING\n\n"

printf `mysql -h totara-sandbox-usa.cbi8awzlbvzi.us-west-2.rds.amazonaws.com -u root -p${DB_PASSWORD} moodle_ta_uat_${CLIENT_NAME}12_sandbox -e \"UPDATE mdl_config_plugins SET value = '$DASHBOARD_STRING' WHERE plugin = 'auth_dashboard' AND name = 'secret_string';\"`
