Lightblue Quickstarts
=====================

The quickstarts demonstrate Lightblue's features and how to deploy it. They provide small, specific, working examples that can be used as a reference for your own project or to understand to Lightblue behavior and how to use it. We recommend to use puppet option to setup the enviroment in EC2 instance (running in AWS cluster).


Puppet script installation option (Recommened - easier)
-------------------------------------------------------

For puppet installation, use the wizard\_puppet.sh script file to help you to set up all you need for the remote deployment, just need an EC2 instance running which must be medium type due the JBoss default memory configuration (that can be changed using the already configurated erb files). Also THe EC2 instance needs to be associated with a Security Group which allows it to open the SSH port and 8080 port (to remote access and for the web application respectively). 

The wizard\_puppet.sh script will first install the necessary packages and ask the user a couple of question. Then it will  use the 'rake' command (which uses the Rakefile of this directory to get the configurations) to remote access the EC2 instance, deploy the necessary RPMs and start the remote puppet. You can directly call 'rake' command using this a as workspace directory to avoid the overhead of answering the same questions again and again, it will just require some enviroment variables to be provided ( the end of the  wizard\_puppet.sh script will provide the one line of command line code that will expose the configurations to rake).

For puppet modifications, you probably would want to run 'rake add\_hooks' to add a hook into the git repository to check your scripts before any commit.

Shell script installation option 
--------------------------------

There is also the single bash script that may help you with the installation. It requires you to access the machine (using the SSH for example) and run it.


EC2 instance creation and configuration script
----------------------------------------------

The wizard\_puppet.sh script will also get the necessary dependencies to programmably manage your AWS account, just need to provide the Access Keys ([this blog post might help](http://www.cloudberrylab.com/blog/how-to-find-your-aws-access-key-id-and-secret-access-key-and-register-with-cloudberry-s3-explorer/) or inother case, take a look at [Security Credentials tab in the Users page](https://console.aws.amazon.com/iam/home?#users) and create your Access Key).

But to create the EC2 instance, run "rake create\_ec2" command (which will ask for the credentials and for the PEM Key name).


Scripts for understanting and testing
-------------------------------------

Under the demo\_scripts directory there are scripts to test lightblue. [See more examples in the demo folder of the core project](https://github.com/lightblue-platform/lightblue/tree/master/docs/demo) (which uses [shakespeares-monkey](https://github.com/lightblue-platform/shakespeares-monkey)).


# License

The license of lightblue and its quickstarts are [GPLv3](https://www.gnu.org/licenses/gpl.html).  See COPYING in root of project for the full text.
