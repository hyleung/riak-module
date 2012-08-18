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
		source => '/tmp/files/app.config',
		subscribe => Exec['riak-install']
	}

	service { 'riak':
		ensure => running,
		subscribe => File['/etc/riak/app.config']
	}
}