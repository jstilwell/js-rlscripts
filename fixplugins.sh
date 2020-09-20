#!/bin/bash

# RL Plugin Fixer
# Author: Jesse Stilwell <jesse.stilwell@remote-learner.com>

# USAGE:
# ./fixplugins.sh /mnt/code/www/moodle_prod MOODLE_39_STABLE

codedir=$1
gitbranch=$2
filename="dirlist.txt"

# Prompt for git password one time only.
ssh-add /root/.ssh/id_rsa.rlgit

# Get list of subdirectories with .git folders (external plugins)
find $codedir -name ".git" -type d > $filename

while read line; do
# Change directory and move one down. 
cd $line && cd ..
# Checkout branch specified by user.
git fetch origin && git checkout -b $gitbranch origin/$gitbranch
git checkout $gitbranch
done < $filename

rm $filename
