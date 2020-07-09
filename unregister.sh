#!/bin/bash
site_id=$(sed -n 's/site_id = //p' /mnt/data/conf/global.ini)
username=$(printenv LOGNAME)
echo "Unregisterring VM (${site_id})"
/rlscripts/system/system_unregister
echo "Removing UTR Monitoring for VM (${site_id})"
ssh ${username}@aws-bounce.remote-learner.net "rlcloud monitoring del ${site_id}"
