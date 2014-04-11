class rhn (
  $username      = undef,
  $password      = undef,
  $activationkey = undef,
  $force         = false,

){
  if $::osfamily != 'RedHat' {
    fail("Unsupported OS. Can't register ${::operatingsystem} with RHN or Satellite")
  }

  if ($rhn::username == undef or $rhn::password == undef) and $rhn::activationkey == undef {
    notice("The \$rhn::username value is: ${rhn::username}")
    notice("The \$username value is: ${username}")
    notice("The \$rhn::password value is: ${rhn::password}")
    notice("The \$rhn::activationkey value is: ${rhn::activationkey}")
    fail('Need the user and password (or activation key) to register into rhn.')
  }

  $rhn_userpass = $rhn::username ? {
    undef   => '',
    default => " --username ${rhn::username} --password ${rhn::password}",
  }

  $activation_key = $rhn::activationkey ? {
    undef   => '',
    default => " --activationkey ${rhn::activationkey}",
  }

  $command_args = "${rhn::activation_key}${rhn::rhn_userpass}"

  if $rhn::force {
    # Use force when the machine is already registered
    exec { 'rhn_re-register':
      path    => "/usr/local/bin/:/usr/bin:/bin/:/usr/sbin",
      user    => 'root',
      command => "rhnreg_ks --force ${rhn::command_args}",
    }
  } else {
    notice("The xxx /usr/sbin/rhnreg_ks${rhn::command_args}")
    exec { 'rhn_register':
      path    => "/usr/local/bin/:/usr/bin:/bin/:/usr/sbin",
      user    => 'root',
      command => "rhnreg_ks ${rhn::command_args}",
      creates => '/etc/sysconfig/rhn/systemid',
    }
  }

  exec { 'register_with_rhn':
    command => "/usr/sbin/rhn_check -v",
  }
}
