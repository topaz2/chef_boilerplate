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
default[:boilerplate][:git] = {
  use_git_protocol: true
}
default[:boilerplate][:project] = {
  name: 'app'
}

default[:boilerplate][:recipes] =
  case node.platform
  when 'debian', 'ubuntu'
    %w(
      apt_fast apt_packages git gem_packages pip_packages npm_packages bower_packages
      mysql redmine jenkins gitlab
    )
  else
    Chef::Log.warn 'Unsupported platform'
    %w(
      git gem_packages pip_packages npm_packages bower_packages
      mysql redmine jenkins gitlab
    )
  end

default[:boilerplate][:install_packages] = %w(
  ruby1.9.1 ruby1.9.1-dev
  openjdk-7-jdk
  git subversion
  mysql-server libmysql++-dev
  libxml2-dev libxslt-dev libcurl4-gnutls-dev libgecode-dev
  curl imagemagick graphviz
  lv zsh tree axel expect make g++ ccache
  global w3m aspell exuberant-ctags wamerican-huge stunnel4 libnotify-bin
  emacs-goodies-el debian-el gettext-el
  vim
  iftop iotop iperf nethogs sysstat
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
default[:boilerplate][:gitlab] = {
  host: 'gitlab.local',
  port: '8081',
  path: '/'
}
default[:boilerplate][:redmine] = false
default[:boilerplate][:jenkins] = {
  executors: 4,
  host: 'jenkins.local',
  port: '8080',
  path: '/',
  mail: {
    recipients: nil
  }
}
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
