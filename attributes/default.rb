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
