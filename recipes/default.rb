#
# Cookbook Name:: boilerplate
# Recipe:: default
#
# Copyright (C) 2014, Jun Nishikawa <topaz2@m0n0m0n0.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# %w( python-software-properties ).each do |pkg|
#   package pkg do
#     action [:install]
#   end
# end

# include_recipe 'apt'

packages = []
case node.normal['platform']
when 'debian'
  package 'apt-spy'

  execute 'choose fastest mirror' do
    command "apt-spy -s #{node.normal.boilerplate.country} -d stable"
    not_if { ::File.exist?('/etc/apt/sources.list.d/apt-spy.list') }
  end

  # Add extra repos
  apt_repository "emacs-#{node[:lsb][:codename]}" do
    uri 'http://emacs.naquadah.org/'
    components ['stable/']
    key 'http://emacs.naquadah.org/key.gpg'
    not_if { ::File.exist?("/etc/apt/sources.list.d/emacs-#{node[:lsb][:codename]}.list") }
  end
  packages.push('emacs-snapshot')
when 'ubuntu'
  execute 'choose fastest mirror' do
    command "sed -i 's/us.archive/#{node.normal.boilerplate.country}.archive/g' /etc/apt/sources.list"
  end

  # Add extra repos
  execute 'add latest emacs repository' do
    command 'add-apt-repository -y ppa:cassou/emacs; apt-get update'
    not_if { ::File.exist?("/etc/apt/sources.list.d/cassou-emacs-#{node[:lsb][:codename]}.list") }
  end

  execute 'add latest nodejs repository' do
    command 'add-apt-repository -y ppa:chris-lea/node.js; apt-get update'
    not_if { ::File.exist?("/etc/apt/sources.list.d/chris-lea-node_js-#{node[:lsb][:codename]}.list") }
  end
  packages.push('emacs24')
end

# Add extra repos
apt_repository "jenkins-#{node[:lsb][:codename]}" do
  uri 'http://pkg.jenkins-ci.org/debian'
  components ['binary/']
  key 'http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key'
  not_if { ::File.exist?("/etc/apt/sources.list.d/jenkins-#{node[:lsb][:codename]}.list") }
end

# Install packages necessary for this project
packages.concat(%w(
  ruby1.9.1 ruby1.9.1-dev
  openjdk-7-jdk
  git subversion
  apache2-utils apache2.2-bin apache2.2-common
  mysql-server libmysql++-dev
  libxml2-dev libxslt-dev libcurl4-gnutls-dev
  curl imagemagick graphviz
  lv zsh tree axel expect make g++
  global w3m aspell exuberant-ctags wamerican-huge stunnel4 libnotify-bin
  emacs-goodies-el debian-el gettext-el
  vim
  iftop iotop iperf nethogs sysstat
))
%w( jenkins ).each do |optional|
  packages << optional if node.normal.boilerplate.key?(optional) && node.normal.boilerplate[optional] != false
end

dependencies = []
packages.each do |pkg|
  if node.default[:versions][pkg].kind_of? String
    dependencies << [pkg, node.default[:versions][pkg]].join('=')
  else
    dependencies << pkg
  end
end

execute 'apt-get install' do
  command "export DEBIAN_FRONTEND=noninteractive && apt-get -q -y install #{dependencies.join(' ')}"
end

# packages.each do |pkg|
#   package pkg do
#     action [:install, :upgrade]
#     version node.default[:versions][pkg] if node.default[:versions][pkg].kind_of? String
#   end
# end

# Clone existing project
if node[:boilerplate].key?(:git)
  execute "clone project into #{node[:boilerplate][:project_root]}" do
    command "cd #{node[:boilerplate][:document_root]}; git clone #{node[:boilerplate][:git][:uri]}"
    not_if { ::File.exist?(node[:boilerplate][:project_root]) }
  end
end

# Install packages
execute 'install bundler' do
  command 'gem i bundler'
end

execute 'install gem packages' do
  command "cd #{node[:boilerplate][:project_root]}; bundle"
  only_if { ::File.exist?("#{node[:boilerplate][:project_root]}/Gemfile") }
end

%w( yui_compressor jslint closure_compiler ).each do |package|
  execute "juicer install #{package}" do
    command "juicer install #{package}"
    not_if { ::File.exist?("#{ENV['HOME']}/.juicer/lib/#{package}") }
  end
end

# execute 'install npm packages' do
#   command 'npm -g install jshint grunt-cli gfms'
# end

## Setup apache
include_recipe 'apache2'

%w( proxy proxy_http ).each do |m|
  apache_module m do
    enable true
  end
end

%w( jenkins redmine ).each do |site|
  next unless node[:boilerplate][site]
  template "#{node[:apache][:dir]}/sites-available/#{site}" do
    source "apache2/#{site}.erb"
    notifies :restart, 'service[apache2]'
  end
  apache_site site do
    enable true
  end
end

## Setup mysql
include_recipe 'mysql::client'
include_recipe 'mysql::server'

mysql_connection_info = {
  :host => 'localhost',
  :username => 'root',
  :password => node.normal['mysql']['server_root_password']
}

mysql_database_user 'test' do
  connection mysql_connection_info
  password 'test'
  action :grant
end

template '/etc/mysql/conf.d/my.cnf' do
  source 'mysql/my.cnf'
  notifies :restart, 'mysql_service[default]'
end

## Setup jenkins
if node.normal.boilerplate.key?(:jenkins) && node.normal.boilerplate[:jenkins]
  group 'jenkins' do
    action [:create, :modify]
    members 'jenkins'
    append true
  end

  include_recipe 'jenkins::master'

  template '/etc/default/jenkins' do
    source 'default/jenkins.erb'
    notifies :restart, 'service[jenkins]'
  end

  %w(
    credentials ghprb git-client git github-api github scm-api ssh-credentials anything-goes-formatter
    ansicolor ruby-runtime vagrant
  ).each do |p|
    jenkins_plugin p
  end
end
