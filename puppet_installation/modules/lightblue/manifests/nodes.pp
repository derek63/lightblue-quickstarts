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
    jboss_dist     => 'eap.tar.gz',
    jboss_user     => 'eap',
    jboss_group    => 'eap',
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
    command => "rpm -iv /tmp/rest-metadata.rpm",
    path => ['/usr/bin', '/bin', '/sbin', '/usr/sbin'],
  }->
  exec { 'install the rest-crud':
    command => "rpm -iv /tmp/rest-crud.rpm",
    path => ['/usr/bin', '/bin', '/sbin', '/usr/sbin'],
  }
}
