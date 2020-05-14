#!/bin/bash  
echo "Refreshing code..."  
rsync -avv --progress --exclude=/config.php /mnt/code/www/moodle_prod/ /mnt/code/www/moodle_sand
echo "Refreshing data..."  
sudo /rlscripts/moodle/moodle_sandbox_refresh_data --dirsrc=/mnt/data/moodledata_prod --dirdest=/mnt/data/moodledata_sand --excludes=sessions,cache,localcache,muc,lock -y
echo "Preparing sandbox database..."
sudo mysqladmin drop moodle_sand && sudo mysqladmin create moodle_sand
echo "Refreshing database without logstore table..."
sudo mysqldump -v moodle_prod --no-data | sudo mysql moodle_sand && sudo mysqldump -v moodle_prod --no-create-info --ignore-table=moodle_prod.mdl_logstore_standard_log | sudo mysql moodle_sand
echo "Running upgrade script..."
/rlscripts/moodle/moodle_upgrade --skip-sizecheck --skip-backup --skip-refresh /mnt/code/www/moodle_prod/
echo "Fixing permissions..."
sudo /rlscripts/moodle/moodle_fix_permissions /mnt/code/www/moodle_sand
