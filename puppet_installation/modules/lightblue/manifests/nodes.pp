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

  package { 'mongodb-server.x86_64':
    ensure => installed,
  }->

  package { 'mongodb.x86_64':
    ensure => installed,
  }->

  exec { 'install the rest-metadata':
    command => "rpm -Fiv /tmp/rest-metadata.rpm || true",
    path    => ['/usr/bin', '/bin', '/sbin', '/usr/sbin'],
    require =>  Class['jboss_as'],
  }->

  exec { 'install the rest-crud':
    command => "rpm -Fiv /tmp/rest-crud.rpm || true",
    path    => ['/usr/bin', '/bin', '/sbin', '/usr/sbin'],
    require =>  Class['jboss_as'],
  }->

  jboss_as::jbossmodule{'Set jboss module directory':
   jboss_home => '/usr/share/jboss',
   moduledir  => 'com.redhat.lightblue',
  }->

  #You may use variables (like $template_module_path in jbossmodule) to set dynamic content
  class{'jboss_as::jbossmodulefile':
   jboss_home         => '/usr/share/jboss',
   moduledir          => 'com.redhat.lightblue',
   configuration_file => 'config.properties',
   owner              => 'jboss_as',
   group              => 'jboss_as',
   content            => template('config.properties.erb'),
  }->

  class{'jboss_as::jbossmodulefile':
   jboss_home         => '/usr/share/jboss',
   moduledir          => 'com.redhat.lightblue',
   configuration_file => 'lightblue-crud.json',
   owner              => 'jboss_as',
   group              => 'jboss_as',
   content            => template('lightblue-crud.json.erb'),
  }->

  class{'jboss_as::jbossmodulefile':
   jboss_home         => '/usr/share/jboss',
   moduledir          => 'com.redhat.lightblue',
   configuration_file => 'lightblue-metadata.json',
   owner              => 'jboss_as',
   group              => 'jboss_as',
   content            => template('lightblue-metadata.json.erb'),
  }->

  exec { 'config mongodb.conf: smallfiles':
    command => "echo 'smallfiles = true' | tee -a /etc/mongodb.conf",
    path    => ['/usr/bin', '/bin', '/sbin', '/usr/sbin'],
    unless  => "grep --quiet smallfiles /etc/mongodb.conf 2>/dev/null"
  }->

  service { "mongod":
    ensure => "running",
  }->

  exec { 'Network':
    command => "iptables -I INPUT 1 -p tcp --dport 8080 -j ACCEPT",
    path    => ['/usr/bin', '/bin', '/sbin', '/usr/sbin'],
    unless  => "iptables -L | grep --quiet 'tcp dpt:webcache'  2>/dev/null"
  }

}
