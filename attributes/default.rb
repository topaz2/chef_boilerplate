default[:boilerplate] = {
  :apt_fast => true,
  :apt_packages => true,
  :gem_packages => true,
  :npm_packages => true,
  :bower_packages => true,
  :apache2 => true,
  :mysql => true,
  :apt_command => 'apt-get'
}
default[:boilerplate][:country] = 'us'
default[:boilerplate][:admin] = {
  :mail => "webmaster@#{node[:fqdn]}"
}
default[:boilerplate][:document_root] = '/var/www'
default[:boilerplate][:git] = {
  :use_git_procotol => true
}
default[:boilerplate][:project] = {
  :name => 'app'
}

default[:boilerplate][:app] = {
  :repo => {
    :type => 'git',
    :uri => nil
  },
  :host => 'app.local',
  :port => '80',
  :path => '/'
}
default[:boilerplate][:docs] = {
  :repo => {
    :type => 'git',
    :uri => nil
  },
  :host => 'docs.local',
  :port => '80',
  :path => '/'
}
default[:boilerplate][:cookbook] = {
  :repo => {
    :type => 'git',
    :uri => nil
  }
}
default[:boilerplate][:gitlab] = {
  :host => 'gitlab.local',
  :port => '8081',
  :path => '/'
}
default[:boilerplate][:redmine] = false
default[:boilerplate][:jenkins] = {
  :host => 'jenkins.local',
  :port => '8080',
  :path => '/',
  :mail => {
    :recipients => nil
  }
}

default[:boilerplate][:app_root] = "#{node[:boilerplate][:document_root]}/app"
default[:boilerplate][:docs_root] = "#{node[:boilerplate][:document_root]}/docs"
