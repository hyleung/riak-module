class riak {


	package { "curl":
		ensure => installed
	}

	group { "puppet":
		ensure => "present",
	}

	#ensure directory for downloads
	file { '/tmp/downloads':
		ensure => directory,
		group => 'puppet'
	}

	#install openssl
	package {
		"openssl":
		ensure => installed
	}
	$pem_file = 'cert.pem'
	$key_file = 'key.pem'
	exec { "/usr/bin/openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout $key_file -out $pem_file -subj  '/CN=com.foresee'":
            cwd => "/etc/riak/",
            creates => "/etc/riak/ssl/$pem_file"}

	#install libssl
	package { "libssl0.9.8":
		ensure => installed
	}
	#download the Riak binary package
	exec { 'wget-riak':
		command => '/usr/bin/wget http://downloads.basho.com.s3-website-us-east-1.amazonaws.com/riak/CURRENT/ubuntu/lucid/riak_1.2.0-1_i386.deb -O /tmp/downloads/riak_1.2.0-1_i386.deb',
		creates => "/tmp/downloads/riak_1.2.0-1_i386.deb",
		subscribe =>File['/tmp/downloads']
	}

	exec { 'riak-install':
		command => '/usr/bin/dpkg -i /tmp/downloads/riak_1.2.0-1_i386.deb',
		user => root,
		subscribe => Exec['wget-riak']
	}

	#riak config file
	file { '/etc/riak/app.config':
		ensure => present,
		owner => 'root',
		group => 'root',
		source => 'puppet:///modules/riak/app.config',
		subscribe => Exec['riak-install']
	}

	service { 'riak':
		ensure => running,
		subscribe => File['/etc/riak/app.config']
	}
}