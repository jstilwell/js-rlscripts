#!/bin/bash
site_id=$(sed -n 's/site_id = //p' /mnt/data/conf/global.ini)
username=$(printenv LOGNAME)
echo "Unregisterring VM (${site_id})"
yes Y | /rlscripts/system/system_unregister
echo "Removing UTR Monitoring for VM (${site_id})"
ssh-keyscan aws-bounce.remote-learner.net >> ~/.ssh/known_hosts
ssh ${username}@aws-bounce.remote-learner.net "rlcloud monitoring del ${site_id}"
echo "Shutting down VM -> rl_decom_site -s ${site_id}"
sudo shutdown -h now
