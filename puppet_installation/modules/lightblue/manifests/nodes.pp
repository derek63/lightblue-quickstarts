node default {
  case $::osfamily {
    RedHat  : { $supported = true }
    default : { 
      notice("The ${module_name} module is not supported on ${::osfamily} based systems")
      fail("The ${module_name} module is not supported on ${::osfamily} based systems") 
    }
  }

  include croot
  include puppet

  class { 'rhn':
    username => $::rhnuser,
    password => $::rhnpass,
  }->

  package { 'java-1.7.0-openjdk-devel':
    ensure   => installed,
  }->


  class { 'jboss_as':
    jboss_dist     => 'eap.zip',
    jboss_user     => 'jboss-as',
    jboss_group    => 'jboss-as',
    jboss_home     => '/usr/share/jboss',
    staging_dir    => '/tmp/puppet-staging/jboss_as',
    standalone_tpl => 'jboss_as/standalone.xml.erb',
    download       => true,
    username       => $::rhnuser,
    password       => $::rhnpass,
  }->

##from epel, but it is version 2.4
#  package { 'mongodb-server.x86_64':
#    ensure => installed,
#  }->
#  package { 'mongodb.x86_64':
#    ensure => installed,
#  }->


## from mongo repository (2.6)
  exec { 'mongo repo':
    command => 'echo -e "[mongodb]\nname=MongoDB Repository\nbaseurl=http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/\ngpgcheck=0\nenabled=1" | sudo tee  /etc/yum.repos.d/mongodb.repo || true',
    path    => ['/usr/bin', '/bin', '/sbin', '/usr/sbin'],
  }->
 
  package {'mongodb-org': ensure => installed, } ->

  exec { 'install the rest-metadata':
    command => "rpm -iv /tmp/rest-metadata.rpm || true",
    path    => ['/usr/bin', '/bin', '/sbin', '/usr/sbin'],
    require =>  Class['jboss_as'],
  }->
  exec { 'update the rest-metadata':
    command => "rpm -Fiv /tmp/rest-metadata.rpm || true",
    path    => ['/usr/bin', '/bin', '/sbin', '/usr/sbin'],
    require =>  Class['jboss_as'],
  }->

  exec { 'install the rest-crud':
    command => "rpm -iv /tmp/rest-crud.rpm || true",
    path    => ['/usr/bin', '/bin', '/sbin', '/usr/sbin'],
    require =>  Class['jboss_as'],
  }->
  exec { 'update the rest-crud':
    command => "rpm -Fiv /tmp/rest-crud.rpm || true",
    path    => ['/usr/bin', '/bin', '/sbin', '/usr/sbin'],
    require =>  Class['jboss_as'],
  }->

#  class{'jboss_as::jbossmodule':
  jboss_as::jbossmodule{'Set jboss module directory':
   jboss_home => '/usr/share/jboss',
   moduledir  => 'com/redhat/lightblue',
   owner              => 'jboss-as',
   group              => 'jboss-as',
  }->

  #You may use variables (like $template_module_path in jbossmodule) to set dynamic content
#  class{'jboss_as::jbossmodulefile':
  jboss_as::jbossmodulefile{'Set config.properties':
   jboss_home         => '/usr/share/jboss',
   moduledir          => 'com/redhat/lightblue',
   configuration_file => 'config.properties',
   owner              => 'jboss-as',
   group              => 'jboss-as',
   content            => template('lightblue/config.properties.erb'),
  }->

#  class{'jboss_as::jbossmodulefile':
  jboss_as::jbossmodulefile{'Set lightblue-crud.json':
   jboss_home         => '/usr/share/jboss',
   moduledir          => 'com/redhat/lightblue',
   configuration_file => 'lightblue-crud.json',
   owner              => 'jboss-as',
   group              => 'jboss-as',
   content            => template('lightblue/lightblue-crud.json.erb'),
  }->

#  class{'jboss_as::jbossmodulefile':
  jboss_as::jbossmodulefile{'Set lightblue-metadata.json':
   jboss_home         => '/usr/share/jboss',
   moduledir          => 'com/redhat/lightblue',
   configuration_file => 'lightblue-metadata.json',
   owner              => 'jboss-as',
   group              => 'jboss-as',
   content            => template('lightblue/lightblue-metadata.json.erb'),
  }->

#  class{'jboss_as::jbossmodulefile':
  jboss_as::jbossmodulefile{'Set datasources.json':
   jboss_home         => '/usr/share/jboss',
   moduledir          => 'com/redhat/lightblue',
   configuration_file => 'datasources.json',
   owner              => 'jboss-as',
   group              => 'jboss-as',
   content            => template('lightblue/datasources.json.erb'),
  }->

  exec { 'config mongodb.conf: smallfiles':
    command => "echo 'smallfiles = true' | tee -a /etc/mongodb.conf",
    path    => ['/usr/bin', '/bin', '/sbin', '/usr/sbin'],
    unless  => "grep --quiet smallfiles /etc/mongodb.conf 2>/dev/null"
  }->

##for epel or after configured the mongos`s RPM file
#  service { "mongod":
#    ensure => "running",
#  }->

##for mongo repository
  file { "/data/db":
    ensure => "directory",
  }->
  exec { 'create mongo folder (2.6 req)':
    command => "sudo chmod 777 /data/db || true",
    path    => ['/usr/bin', '/bin', '/sbin', '/usr/sbin'],
    unless  => "grep --quiet smallfiles /etc/mongodb.conf 2>/dev/null"
  }->
##
  exec { 'start mongo with smallfiles':
    command => "nohup mongod --config /etc/mongodb.conf & || true",
    path    => ['/usr/bin', '/bin', '/sbin', '/usr/sbin'],
    unless  => "grep --quiet smallfiles /etc/mongodb.conf 2>/dev/null"
  }->

  exec { 'Network':
    command => "iptables -I INPUT 1 -p tcp --dport 8080 -j ACCEPT",
    path    => ['/usr/bin', '/bin', '/sbin', '/usr/sbin'],
    unless  => "iptables -L | grep --quiet 'tcp dpt:webcache'  2>/dev/null"
  }

}
