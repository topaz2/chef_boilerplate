default[:boilerplate][:country] = 'us'
default[:boilerplate][:document_root] = '/var/www'
default[:boilerplate][:redmine] = {
  :host => 'localhost',
  :port => '80',
  :path => '/redmine'
}
default[:boilerplate][:jenkins] = {
  :host => 'localhost',
  :port => '8080',
  :path => '/jenkins'
}
default[:boilerplate][:project_root] = node[:boilerplate][:document_root]
default[:boilerplate][:docs_root] = "#{node[:boilerplate][:document_root]}/docs"
if node[:boilerplate].key?(:git)
  default[:boilerplate][:project_root] = [
    node[:boilerplate][:document_root],
    node[:boilerplate][:git][:uri].gsub(/.*\/([\w]+)$/, '\1')
  ].join('/')
end
