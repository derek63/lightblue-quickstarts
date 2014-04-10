node default {
  case $::osfamily {
    RedHat  : { $supported = true }
    default : { fail("The ${module_name} module is not supported on ${::osfamily} based systems") }
  }

  include croot
  include puppet
  class { 'rhn':
    username => $::rhnuser,
    password => $::rhnpass,
    force    => true,
  }
}
