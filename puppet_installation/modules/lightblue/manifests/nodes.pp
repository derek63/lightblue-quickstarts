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
  include mongodb

  class { 'rhn':
    username => $::rhnuser,
    password => $::rhnpass,
  }->

  class { 'java':
    distribution => 'jdk',
    version      => 'latest',
  }->

  class { 'maven::maven':
    version => "3.2.1", 
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

mongodb_database { testdb:
  ensure   => present,
  tries    => 10,
  require  => Class['mongodb::server'],
}->
mongodb_user { testuser:
  ensure        => present,
  password_hash => mongodb_password('testuser', 'p@ssw0rd'),
  database      => testdb,
  roles         => ['readWrite', 'dbAdmin'],
  tries         => 10,
  require       => Class['mongodb::server'],
}->

  file { "/usr/src/lightblue":
    ensure => directory,
    purge => true,
    force => true,
  }->

  git::repo{'git_lightblue':
    path   => "/usr/src/lightblue",
    source => 'git://github.com/lightblue-platform/lightblue.git'
  }->

  exec { 'build-lightblue':
    user    => $::remoteuser,
    cwd     => "/usr/src/lightblue",
    command => 'mvn clean install',
    path    => "/usr/local/bin/:/usr/bin:/bin/",
  }->

  exec { 'move-lightblue':
    path    => $::path,
    cwd     => "/usr/src/lightblue",
    command => 'mv rest/crud/target/rest-crud* /tmp/rest-crud.war && mv rest/metadata/target/rest-metadata* /tmp/rest-metadata.war ',
  }->

  jboss_as::deploy { 'rest-metadata.war':
    pkg         => 'rest-metadata.war', 
    tmp         => true,
    jboss_user  => 'jboss',
  }->
  jboss_as::deploy { 'rest-crud.war':
    pkg         => 'rest-crud.war', 
    tmp         => true,
    jboss_user  => 'jboss',
  }

}
