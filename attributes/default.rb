default[:boilerplate][:country] = 'us'
default[:boilerplate][:document_root] = '/var/www'
default[:boilerplate][:project] = {
  :name => 'app'
}
default[:boilerplate][:app] = {
  :host => 'app.local',
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
  :path => '/'
}
default[:boilerplate][:app_root] = "#{node[:boilerplate][:document_root]}/app"
default[:boilerplate][:docs_root] = "#{node[:boilerplate][:document_root]}/docs"
