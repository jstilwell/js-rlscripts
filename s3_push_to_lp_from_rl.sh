#!/bin/bash
#
# RL to LP Sandbox Migration - Push to S3
# AUTHOR: Jesse Stilwell <jesse.stilwell@learningpool.com>
#
# DIRECTIONS: Run as root from a RL Backtrack VM spun up from a snapshot of the production site
#             that you are creating a LP LMS sandbox for.
#


# Get variable information from user to use later
read -p "Enter RL Client Name (for LP directory name): " CLIENT_NAME
read -p "Enter AWS S3 Key: " AWS_S3_KEY
read -s -p "Enter AWS S3 Secret: " AWS_S3_SECRET

# Install pv for mysqldump progress
yum install pv -y

# Install AWS CLI tool and then clean up after yourself
cd ~
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm awscliv2.zip
rm -rf ./aws

# Setup AWS client/secret for S3
aws configure set aws_access_key_id "$AWS_S3_KEY"
aws configure set aws_secret_access_key "$AWS_S3_SECRET"

# Dump the database to /mnt/data/moodle.sql
mysqldump moodle_prod | pv > /mnt/data/moodle.sql

# Sync RL Moodle Data to LP Sandbox S3 Bucket
# Exclude: cache, sessions, cronlogs, trashdir, .tar.gz files (db backups)
cd /mnt/data
aws s3 sync ./moodledata_prod s3://lp-rl-migration/$CLIENT_NAME/moodledata --exclude "*envcode/*" --exclude "*cache/*" --exclude "*sessions/*" --exclude "*cronlogs/*" --exclude "*.tar.gz" --exclude "*trashdir/*"

# Copy Database Dump to LP Sandbox S3 Bucket
cd /mnt/data
aws s3 cp ./moodle.sql s3://lp-rl-migration/$CLIENT_NAME/moodle.sql
