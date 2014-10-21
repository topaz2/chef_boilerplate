default[:boilerplate] = {
  repo: {
    type: 'git',
    uri: 'https://github.com/topaz2/chef_boilerplate.git'
  },
  apt_fast: true,
  apt_packages: true,
  gem_packages: true,
  pip_packages: true,
  npm_packages: true,
  bower_packages: true,
  apache2: true,
  mysql: true,
  apt_command: 'apt-get'
}
default[:boilerplate][:country] = 'us'
default[:boilerplate][:admin] = {
  mail: "webmaster@#{node[:fqdn]}"
}
default[:boilerplate][:document_root] = '/var/www'
default[:boilerplate][:project] = {
  name: 'app'
}

default[:boilerplate][:recipes] =
  case node[:platform]
  when 'debian', 'ubuntu'
    %w(
      apt_fast apt_packages gem_packages pip_packages npm_packages bower_packages
      apache2 mysql redmine
    )
  else
    Chef::Log.warn 'Unsupported platform'
    %w(
      gem_packages pip_packages npm_packages bower_packages
      apache2 mysql redmine
    )
  end

default[:boilerplate][:install_packages] = %w(
  ant apache2-mpm-prefork aspell axel
  ccache curl
  debian-el
  emacs-goodies-el expect exuberant-ctags
  g++ gettext-el git global graphviz
  iftop imagemagick iotop iperf
  libcurl4-gnutls-dev libffi-dev libgecode-dev libmysql++-dev libnotify-bin libxml2-dev libxslt-dev lv
  make mysql-server
  nethogs nfs-server
  openjdk-7-jdk
  ruby1.9.1 ruby1.9.1-dev
  stunnel4 subversion sysstat
  tree
  unzip
  vim
  w3m wamerican-huge
  zsh
)

default[:boilerplate][:app] = {
  repo: {
    type: 'git',
    uri: nil
  },
  host: 'app.local',
  port: '80',
  path: '/'
}
default[:boilerplate][:docs] = {
  repo: {
    type: 'git',
    uri: nil
  },
  host: 'docs.local',
  port: '80',
  path: '/'
}
default[:boilerplate][:cookbook] = {
  repo: {
    type: 'git',
    uri: nil
  }
}
default[:boilerplate][:redmine] = false
default[:boilerplate][:backup] = {
  schedule: {
    archive_local: {
      strategy: 'cron.daily'
    },
    archive_remote: {
      strategy: 'cron.daily'
    },
    purge: {
      strategy: 'cron.daily',
      duration: '+90'
    }
  },
  from: {
    host: 'localhost',
    port: '22',
    path: '/var/local/backup',
    user: node[:current_user],
    key: nil
  },
  to: {
    host: 'localhost',
    port: '22',
    path: '/var/local/backup',
    user: node[:current_user],
    key: nil
  }
}

default[:boilerplate][:app_root] = "#{node[:boilerplate][:document_root]}/app"
default[:boilerplate][:docs_root] = "#{node[:boilerplate][:document_root]}/docs"
