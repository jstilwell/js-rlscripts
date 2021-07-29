#!/bin/bash
#
# Overwrite Site from Attached Snapshot
# AUTHOR: Jesse Stilwell <jesse.stilwell@learningpool.com>
#
# DIRECTIONS: Run as root from a RL Backtrack VM spun up from a snapshot of the production site
#             that you are creating a LP LMS sandbox for.
#

# Exit if we're not root
if ! [ $(id -u) = 0 ]; then
   echo "This script must be run as root!" 
   exit 1
fi

# Stop MySQL
service mysql stop

# Remove files for current site
rm -rf /mnt/code/www/moodle_prod
rm -rf /mnt/data/moodledata_prod
rm -rf /mnt/db/mysql

# Copy database from snapshot
rsync -avv /snapshot/db/mysql/ /mnt/db/mysql

# Remove ib log files
rm /mnt/db/mysql/ib_logfile0
rm /mnt/db/mysql/ib_logfile1

# Copy LMS code from snapshot
rsync -avv /snapshot/db/mysql/ /mnt/db/mysql

# Copy LMS data from snapshot
rsync -avv /snapshot/data/moodledata_prod/ /mnt/data/moodledata_prod

# Start MySQL, run mysql_upgrade, restart MySQL
service mysql start
mysql_upgrade
service mysql restart

# Print instructions for next steps
printf "\nFix URL: vim /mnt/code/www/moodle_prod/config.php\n"
