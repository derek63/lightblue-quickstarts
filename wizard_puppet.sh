#!/bin/sh

# This file intead to make easier the use of the enviroment variables (especially for the first time or single use. The user might also set the enviroment variable by his one on the current shell so the rake will be able to work fine

echo "Please enter the path to the PEM file to access the aws's ec2 instance (hit enter for default, ~/.ssh/soa.pem):"
read    PATH_PEM_KEY
echo "Please enter the IP/DNS to the target EC2 instance:"
read    REMOTE_TARGET
echo "Please enter the user of the target EC2 instance (hit enter for default, ec2-user ):"
read    REMOTE_USER
echo "Please enter the new hostname you want for the machine (hit enter for default, lightblue-dev ):"
read    HOSTNAME
echo "Please enter your red hat access user:"
read    RHN_USER
echo "Please enter your red hat access password:"
read -s RHN_PASS



PATH_PEM_KEY=${PATH_PEM_KEY:-"~/.ssh/soa.pem"}
#REMOTE_TARGET=${REMOTE_TARGET:-""} # You can add your default IP here
REMOTE_USER=${REMOTE_USER:-"ec2-user"}
HOSTNAME=${HOSTNAME:-"lightblue-dev"}
#RHN_USER=${RHN_USER:-""}           # You can add your default rhn user here
#RHN_PASS=${RHN_PASS:-""}           # You can add your default rhn pass here



# Default (no-arguments) rake program will process the Rakefile
rake
