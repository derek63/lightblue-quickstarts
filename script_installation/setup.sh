#!/bin/sh

# #Create a new Key Pair in AWS (here we named it as 'soa.pem')
# chmod 400 ~/Downloads/soa.pem
# #Create a new EC2 (VM) in AWS (we are using Red Hat Enterprise Linux 6.4 - ami-b8a63b88 and we are associating 'soa.pem' to it) and get its public (floating) IP (here we are using 'x.x.x.x')
# scp -i ~/Downloads/soa.pem ~/Downloads/setup.sh ec2-user@x.x.x.x:~/setup.sh
# ssh -i ~/Downloads/soa.pem  ec2-user@x.x.x.x 
# ./setup.sh
# #follow the instructions

#echo -e "new_password\nnew_password" | (passwd --stdin root) #maybe change the root password

echo "Please enter your red hat access user:"
read user
echo "Please enter your red hat access password:"
read -s pass

user=$(python -c "import urllib; print urllib.quote('''$user''')") 
pass=$(python -c "import urllib; print urllib.quote('''$pass''')") 
#echo 'username='$user'&password='$pass' '

echo "It will take several minutes to download, install and configure everything, please wait."

curl -L -c cookies.txt -o eap.zip 'https://www.redhat.com/wapps/sso/login.html' -H 'Cookie: rh_omni_tc=70160000000H4AjAAK; s_vnum=1398447830558%26vn%3D1; s_fid=23462B5DD35717AF-145059786A1C7770; s_cc=true; s_nr=1395855837745; s_invisit=true; s_sq=redhatglobal%2Credhatcomglobal%3D%2526pid%253Dhttps%25253A%25252F%25252Fwww.redhat.com%25252Fwapps%25252Fsso%25252Flogin.html%25253FloginError%25253Derror_login%252526redirect%25253Dhttps%25253A%25252F%25252Faccess.redhat.com%25252Fjbossnetwork%25252Frestricted%25252FsoftwareDownload.html%25253FsoftwareId%25253D26463%252523error%2526oid%253DLog%252520In%2526oidt%253D3%2526ot%253DSUBMIT' -H 'Origin: https://www.redhat.com' -H 'Accept-Encoding: gzip,deflate,sdch' -H 'Accept-Language: en-US,en;q=0.8,en-GB;q=0.6,pt-BR;q=0.4,pt;q=0.2,fr;q=0.2,es-419;q=0.2,es;q=0.2' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.117 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Cache-Control: max-age=0' -H 'Referer: https://www.redhat.com/wapps/sso/login.html?loginError=error_login&redirect=https://access.redhat.com/jbossnetwork/restricted/softwareDownload.html?softwareId=26463' -H 'Connection: keep-alive' --data 'username='$user'&password='$pass'&_flowId=legacy-login-flow&redirect=https%3A%2F%2Faccess.redhat.com%2Fjbossnetwork%2Frestricted%2FsoftwareDownload.html%3FsoftwareId%3D26463&failureRedirect=http%3A%2F%2Fwww.redhat.com%2Fwapps%2Fsso%2Flogin.html' --compressed

rm cookies.txt

curl -o maven.zip http://www.us.apache.org/dist/maven/maven-3/3.2.1/binaries/apache-maven-3.2.1-bin.zip

curl -o mongodb.tgz http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-2.4.9.tgz 
#we can change to install using yum -> http://docs.mongodb.org/manual/tutorial/install-mongodb-on-red-hat-centos-or-fedora-linux/

sudo yum install -q -y git java-1.7.0-openjdk-devel.x86_64 

tar -zxvf mongodb.tgz

unzip -q eap.zip

sudo unzip -q maven.zip
sudo mv -f apache* /opt/
if [ ! -f /etc/profile.d/maven.sh ]; then
   sudo chmod 777  /opt/apache-maven-3.2.1/ -R
   sudo touch /etc/profile.d/maven.sh
   sudo chmod 777 /etc/profile.d/maven.sh
   sudo echo 'export M2_HOME=/opt/apache-maven-3.2.1' >>/etc/profile.d/maven.sh
   sudo echo 'export M2=$M2_HOME/bin' >>/etc/profile.d/maven.sh
   sudo echo 'PATH=$M2:$PATH' >>/etc/profile.d/maven.sh
   sudo echo 'export JAVA_HOME=/usr/lib/jvm/java' >>/etc/profile.d/maven.sh
   #sudo sed '23s/^#JAVA_HOME/JAVA_HOME/' /etc/java/java.conf
   #source /etc/java/java.conf
   #export JAVA_HOME
fi

source /etc/profile.d/maven.sh

git clone https://github.com/lightblue-platform/lightblue

cd lightblue

mvn -q clean install

cp ~/lightblue/rest/crud/target/rest-crud* ~/jboss-eap-6.2/standalone/deployments/ 
cp ~/lightblue/rest/metadata/target/rest-metadata* ~/jboss-eap-6.2/standalone/deployments/ 

echo "Please run: ' ~/jboss-eap-6.2/bin/standalone.sh &>/dev/null & '"
echo "You may also run ' source /etc/profile.d/maven.sh ' to set enviroment variables without restarting"
