#!/bin/sh

# This file intead to make easier the use of the enviroment variables (especially for the first time or single use. The user might also set the enviroment variable by his one on the current shell so the rake will be able to work fine

# THe following line is to install lastest packages in teh user enviroment in Non-Fedora OS (using rvm)
OSID=$(lsb_release -si)
if ["$OSID" -ne "Fedora"]; then
	curl -sSL https://get.rvm.io | bash -s stable
	source /home/ec2-user/.rvm/scripts/rvm
	rvm install 1.9.3
	ruby -v
	gem -v
	sudo yum install -q -y git  java-1.7.0-openjdk-devel.x86_64 @development-tools rpm-build #needed to build the project (git to clone. java, maven and the rpm-build to build and run 
fi


echo "Checking missing files to run the script"
sudo yum -y install gcc ruby ruby-devel rubygems rake git # You can remove this line later. ALso, you can choose to not install puppet if you want the git hook validation. #Also, this is needed to run on Fedora, as it has the most recent packages 
gem install aws-sdk # it is necessary to create aws instances

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
echo "Please enter the path to RPM for the rest crud (or enter for default)"
read -s RPM_CRUD
echo "Please enter the path to RPM for the rest metadata (or enter for default)"
read -s RPM_META

PATH_PEM_KEY=${PATH_PEM_KEY:-"~/.ssh/soa.pem"}
REMOTE_TARGET=${REMOTE_TARGET:-"54.187.7.27"} # You can add your default IP here
REMOTE_USER=${REMOTE_USER:-"ec2-user"}
HOSTNAME=${HOSTNAME:-"lightblue-dev"}
RHN_USER=${RHN_USER:-"a"}           # You can add your default rhn user here
RHN_PASS=${RHN_PASS:-"b"}           # You can add your default rhn pass here
RPM_CRUD=${RPM_CRUD:-"~/.m2/repository/com/redhat/lightblue/rest/rest-crud/0.1-SNAPSHOT/rest-crud-0.1-SNAPSHOT-rpm.rpm"}
RPM_META=${RPM_META:-"~/.m2/repository/com/redhat/lightblue/rest/rest-metadata/0.1-SNAPSHOT/rest-metadata-0.1-SNAPSHOT-rpm.rpm"}

export PATH_PEM_KEY
export REMOTE_TARGET
export REMOTE_USER
export HOSTNAME
export RHN_USER
export RHN_PASS
export RPM_CRUD
export RPM_META



# Default (no-arguments) rake program will process the Rakefile
rake


echo "!!!!!!!!!!!!!!"
echo ""
echo "Use the following command to set up the environment variables for next time and the command 'rake'"
echo "export PATH_PEM_KEY='$PATH_PEM_KEY' && export REMOTE_TARGET='$REMOTE_TARGET' && export REMOTE_USER='$REMOTE_USER' && export HOSTNAME='$HOSTNAME' && export RHN_USER='$RHN_USER' && export RHN_PASS='$RHN_PASS' && export RPM_CRUD='$RPM_CRUD' && export RPM_META='$RPM_META'"
echo ""
echo "Remember to set the right Security Group (or configure it by your self) -> https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#SecurityGroups:"
echo "!!!!!!!!!!!!!!"
