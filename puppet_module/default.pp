node default {
  fail('unknown service for demo')
}

node /^dc(1|2)-consul-server-[0-9]+$/ {
  class {'consul':
    version => '0.5.0',
    config_hash => {
      bootstrap_expect => 1,
      addresses => {http => '0.0.0.0'},
      data_dir => '/opt/consul',
      ui_dir => '/opt/consul/ui',
      log_level => 'INFO',
      node_name => $::hostname,
      enable_syslog => true,
      datacenter => $::datacenter_name,
      bind_addr => $::ipaddress_eth1,
      server => true,
      domain => 'demo.local',
    },
  } ->
  exec {'run join cluster':
    cwd       => $consul::config_dir,
    path      => [$consul::bin_dir,'/bin','/usr/bin'],
    command   => "consul join ${::consul_cluster_masters}",
  }
}

node /^dc(1|2)-web-[0-9]+$/ {
  notify{'im a web node!': }

  $web_service = {
    'web' => {
      port => 80,
      check_script => 'service apache2 status',
      check_interval => '5s',
      tags => [$::hostname],
    }
  }

  class {'consul':
    version => '0.5.0',
    services => $web_service,
    config_hash => {
      data_dir => '/opt/consul',
      log_level => 'INFO',
      node_name => $::hostname,
      enable_syslog => true,
      datacenter => $::datacenter_name,
      bind_addr => $::ipaddress_eth1,
      server => false,
      domain => 'demo.local',
    },
  } ->
  exec {'run join cluster':
    cwd       => $consul::config_dir,
    path      => [$consul::bin_dir,'/bin','/usr/bin'],
    command   => "consul join ${::consul_cluster_masters}",
  }
}

node /^dc(1|2)-db-[0-9]+$/ {
  notify{'im a db node!': }

  $db_service = {
    'db' => {
      port => 3306,
      check_script => 'service mysqld status',
      check_interval => '5s',
      tags => [$::hostname, 'sql'],
    }
  }

  class {'consul':
    version => '0.5.0',
    services => $db_service,
    config_hash => {
      data_dir => '/opt/consul',
      log_level => 'INFO',
      node_name => $::hostname,
      enable_syslog => true,
      datacenter => $::datacenter_name,
      bind_addr => $::ipaddress_eth1,
      server => false,
      domain => 'demo.local',
    },
  } ->
  exec {'run join cluster':
    cwd       => $consul::config_dir,
    path      => [$consul::bin_dir,'/bin','/usr/bin'],
    command   => "consul join ${::consul_cluster_masters}",
  }
}
