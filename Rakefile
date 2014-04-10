COMMAND_SSH_PREFIX = 'ssh -t -A -l ' 
REPOSITORY  = 'https://github.com/lightblue-platform/lightblue-quickstarts.git'



PATH_PEM_KEY = ENV['PATH_PEM_KEY']  # The path to AWS key pair (/ your private pem key to access the remote node)
REMOTE_TARGET= ENV['REMOTE_TARGET'] # IP or DNS of the client/target.
REMOTE_USER  = ENV['REMOTE_USER']   # The user of the remote machine
HOSTNAME     = ENV['HOSTNAME']      # Using site.pp and different HOSTNAME, we can set different eviroemnt automatically
RHN_USER     = ENV['RHN_USER']
RHN_PASS     = ENV['RHN_PASS']



task :default => [:setup] #You may add :add_hooks if you have puppet. By default, those are the tasks to run if no argumetn is specificed 



desc "Update the target: ENV['REMOTE_USER']"
task :apply do
  sh "git push"
  sh "#{COMMAND_SSH_PREFIX} #{REMOTE_USER} -i #{PATH_PEM_KEY} #{REMOTE_TARGET} update_quickstarts"
end



desc "Setup for the CLIENT with new hostname HOSTNAME (FOR RHEL ONLY)"
task :setup do
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
    sudo yum -y install gcc ruby ruby-devel rubygems rake git puppet && \
    rm -rf lightblue-quickstarts && \
    git clone #{REPOSITORY} lightblue-quickstarts && \
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
