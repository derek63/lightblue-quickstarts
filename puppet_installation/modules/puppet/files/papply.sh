#! /bin/sh
# Make local puppet installation easier with a no-argument command
sudo -E puppet apply /home/${FACTER_REMOTE_USER}/lightblue-quickstarts/puppet_installation/modules/lightblue/manifests/site.pp --modulepath=/home/${FACTER_REMOTE_USER}/lightblue-quickstarts/puppet_installation/modules/ $*

