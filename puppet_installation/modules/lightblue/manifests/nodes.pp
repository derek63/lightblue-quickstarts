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
    ensure => installed,
  }->


  class { 'jboss_as':
    jboss_dist     => 'eap.zip',
    jboss_user     => 'jboss-as',
    jboss_group    => 'jboss-as',
    jboss_home     => '/usr/share/eap',
    staging_dir    => '/tmp/puppet-staging/jboss_as',
    standalone_tpl => 'jboss_as/standalone.xml.erb',
    download => true,
    username => $::rhnuser,
    password => $::rhnpass,
  }->
  package { 'mongodb-server.x86_64':
    ensure => installed,
  }->
  exec { 'install the rest-metadata':
    command => "rpm -iv /tmp/rest-metadata.rpm || true",
    path    => ['/usr/bin', '/bin', '/sbin', '/usr/sbin'],
    require =>  Class['jboss_as'],
  }->
  exec { 'install the rest-crud':
    command => "rpm -iv /tmp/rest-crud.rpm || true",
    path => ['/usr/bin', '/bin', '/sbin', '/usr/sbin'],
    require =>  Class['jboss_as'],
  }->
  exec { 'config mongodb.conf: smallfiles':
    command => "echo 'smallfiles = true' | sudo tee -a /etc/mongodb.conf",
    path => ['/usr/bin', '/bin', '/sbin', '/usr/sbin'],
    unless => "grep --quiet smallfiles /etc/mongodb.conf 2>/dev/null"
  }->
  service { "mongod":
    ensure => "running",
  }
}
