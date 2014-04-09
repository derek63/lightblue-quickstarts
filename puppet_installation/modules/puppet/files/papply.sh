#! /bin/sh
# Make local puppet installation easier with a no-argument command
sudo puppet apply /home/${USER}/lightblue-quickstarts/puppet_installation/modules/lightblue/manifests/site.pp --modulepath=/home/${USER}/lightblue-quickstarts/puppet_installation/modules/ $*

