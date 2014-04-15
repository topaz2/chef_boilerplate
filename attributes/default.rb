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
default[:boilerplate][:redmine] = {
  :host => 'redmine.local',
  :port => '80',
  :path => '/'
}
default[:boilerplate][:jenkins] = {
  :host => 'jenkins.local',
  :port => '8080',
  :path => '/'
}
default[:boilerplate][:project_root] = node[:boilerplate][:document_root]
default[:boilerplate][:docs_root] = "#{node[:boilerplate][:document_root]}/docs"
if node[:boilerplate].key?(:git)
  default[:boilerplate][:project_root] = [
    node[:boilerplate][:document_root],
    node[:boilerplate][:git][:uri].gsub(/.*\/([\w]+)$/, '\1')
  ].join('/')
end
