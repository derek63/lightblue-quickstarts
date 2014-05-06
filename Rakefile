require 'aws-sdk'

COMMAND_SSH_PREFIX = 'ssh -t -A -l ' 
COMMAND_SCP_PREFIX = 'rsync -rave "ssh -i'
REPOSITORY  = 'https://github.com/lightblue-platform/lightblue-quickstarts.git'

PATH_PEM_KEY = ENV['PATH_PEM_KEY']  # The path to AWS key pair (/ your private pem key to access the remote node)
PATH_PEM_HOME= PATH_PEM_KEY.sub '~', '$HOME'
REMOTE_TARGET= ENV['REMOTE_TARGET'] # IP or DNS of the client/target.
REMOTE_USER  = ENV['REMOTE_USER']   # The user of the remote machine
HOSTNAME     = ENV['HOSTNAME']      # Using site.pp and different HOSTNAME, we can set different eviroemnt automatically
RHN_USER     = ENV['RHN_USER']
RHN_PASS     = ENV['RHN_PASS']
RPM_CRUD     = ENV['RPM_CRUD']
RPM_META     = ENV['RPM_META']




task :default => [:setup] #You may add :add_hooks if you have puppet. By default, those are the tasks to run if no argumetn is specificed 




desc "Update the target: ENV['REMOTE_USER']"
task :apply do
  sh "#{COMMAND_SCP_PREFIX} #{PATH_PEM_HOME}\" #{RPM_CRUD} #{REMOTE_USER}@#{REMOTE_TARGET}:/tmp/rest-crud.rpm"
  sh "#{COMMAND_SCP_PREFIX} #{PATH_PEM_HOME}\" #{RPM_META} #{REMOTE_USER}@#{REMOTE_TARGET}:/tmp/rest-metadata.rpm"
  sh "git push"
  sh "#{COMMAND_SSH_PREFIX} #{REMOTE_USER} -i #{PATH_PEM_KEY} #{REMOTE_TARGET} update_quickstarts"
end




desc "Setup for the CLIENT with new hostname HOSTNAME (FOR RHEL ONLY)"
task :setup do
  sh "#{COMMAND_SCP_PREFIX} #{PATH_PEM_HOME}\" #{RPM_CRUD} #{REMOTE_USER}@#{REMOTE_TARGET}:/tmp/rest-crud.rpm"
  sh "#{COMMAND_SCP_PREFIX} #{PATH_PEM_HOME}\" #{RPM_META} #{REMOTE_USER}@#{REMOTE_TARGET}:/tmp/rest-metadata.rpm"
  commands = <<COMMANDS
    sudo hostname #{HOSTNAME} && \
    echo #{HOSTNAME} | sudo tee /etc/hostname && \
    echo export FACTER_RHN_USER=#{RHN_USER}       | sudo tee -a /root/.bash_profile >/dev/null && \
    echo export FACTER_RHN_PASS=#{RHN_PASS}       | sudo tee -a /root/.bash_profile >/dev/null && \
    echo export FACTER_REMOTE_USER=#{REMOTE_USER} | sudo tee -a /root/.bash_profile >/dev/null && \
    echo export FACTER_RHN_USER=#{RHN_USER}       | sudo tee -a     ~/.bash_profile >/dev/null && \
    echo export FACTER_RHN_PASS=#{RHN_PASS}       | sudo tee -a     ~/.bash_profile >/dev/null && \
    echo export FACTER_REMOTE_USER=#{REMOTE_USER} | sudo tee -a     ~/.bash_profile >/dev/null && \
    source ~/.bash_profile && \
    ( sudo yum -y install http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm || true ) && \
    sudo yum -y install gcc ruby ruby-devel rubygems rake git puppet openssl && \
    rm -rf lightblue-quickstarts && \
    git clone --recursive  #{REPOSITORY} lightblue-quickstarts && \
    sed -i 's/FRHN_USER/#{RHN_USER}/g' lightblue-quickstarts/puppet_installation/modules/facts/lib/facter/required_facts.rb       && \
    sed -i 's/FRHN_PASS/#{RHN_PASS}/g' lightblue-quickstarts/puppet_installation/modules/facts/lib/facter/required_facts.rb       && \
    sed -i 's/FREMOTE_USER/#{REMOTE_USER}/g' lightblue-quickstarts/puppet_installation/modules/facts/lib/facter/required_facts.rb && \
    sudo -E puppet apply --modulepath=/home/#{REMOTE_USER}/lightblue-quickstarts/puppet_installation/modules /home/#{REMOTE_USER}/lightblue-quickstarts/puppet_installation/modules/lightblue/manifests/site.pp
COMMANDS
  sh "#{COMMAND_SSH_PREFIX} #{REMOTE_USER} -i #{PATH_PEM_KEY} #{REMOTE_TARGET} '#{commands}'"
  puts "The client is fully working! You can now checkusing its ip: #{REMOTE_TARGET} "
end




desc "Add syntax check hooks"
task :add_hooks do
  here = File.dirname(__FILE__)
  sh "ln -s #{here}/hooks/syntax.sh #{here}/.git/hooks/pre-commit" #before commit validation
  puts "Hooks added locally"
end

desc "Create EC2 instance"
task :create_ec2 do
  puts "Creating a new EC2 instance...\n\tNote:required to have MY_KEY_PAIR_NAME, ACCESS_KEY_ID and SECRET_ACCESS_KEY enviroment variables\n" 
  
  # Required fields
  id = ENV['ACCESS_KEY_ID']
  secret = ENV['SECRET_ACCESS_KEY']
  key_pair = ENV['MY_KEY_PAIR_NAME'] 
  #optional
  region  = ENV['REGION'] || "us-west-2"
  image  = ENV['IMAGE_ID'] || "ami-b8a63b88"
  instance_type = ENV['INSTANCE_TYPE'] || "m3.medium"
  security_group = ENV['SECURITY_GROUP'] || "Lightblue"

  ec2 = AWS::EC2.new({
    :access_key_id => id,
    :secret_access_key => secret,
    :region => region,
  })

  i = ec2.instances.create(
    :image_id => image,
    :instance_type => instance_type,
    :count => 1, 
    :security_groups => security_group, 
    :key_pair => ec2.key_pairs[key_pair]) 

  puts "Requested to AWS for an instance and it is provision it"

  sleep 10 while i.status == :pending

  puts "Instance created with the public IP="+i.ip_address+" and with ID="+i.id
  puts "run 'export REMOTE_TARGET='"+i.ip_address+"' and then 'rake' to setup the enviroment in that machine"
end
