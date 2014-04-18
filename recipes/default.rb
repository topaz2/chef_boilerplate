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

apt_command = 'apt-get'
case node[:platform]
when 'debian'
  package 'apt-spy'

  execute 'choose fastest mirror' do
    command "apt-spy -s #{node[:boilerplate][:country]} -d stable"
    not_if { ::File.exist?('/etc/apt/sources.list.d/apt-spy.list') }
  end
when 'ubuntu'
  execute 'choose fastest mirror' do
    command "sed -i 's/us.archive/#{node[:boilerplate][:country]}.archive/g' /etc/apt/sources.list"
  end

  # Add apt-fast
  ppa 'apt-fast/stable'
  package 'apt-fast'
  package 'aria2'
  apt_command = 'apt-fast'
  template '/etc/apt-fast.conf' do
    source 'apt-fast/apt-fast.conf.erb'
    notifies :run, 'execute[apt-get update]', :immediately
  end
end

# Add extra repos
packages = []
case node[:platform]
when 'debian'
  apt_repository "emacs-#{node[:lsb][:codename]}" do
    uri 'http://emacs.naquadah.org/'
    components ['stable/']
    key 'http://emacs.naquadah.org/key.gpg'
    not_if { ::File.exist?("/etc/apt/sources.list.d/emacs-#{node[:lsb][:codename]}.list") }
  end
  packages.push('emacs-snapshot')
when 'ubuntu'
  ppa 'cassou/emacs'
  ppa 'chris-lea/node.js'
  packages.push('emacs24')
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

dependencies = []
packages.each do |pkg|
  if node.default[:versions][pkg].kind_of? String
    dependencies << [pkg, node.default[:versions][pkg]].join('=')
  else
    dependencies << pkg
  end
end

execute 'apt-get install' do
  command "export DEBIAN_FRONTEND=noninteractive && #{apt_command} -q -y install #{dependencies.join(' ')}"
end

# packages.each do |pkg|
#   package pkg do
#     action [:install, :upgrade]
#     version node[:versions][pkg] if node[:versions][pkg].kind_of? String
#   end
# end

# Clone existing project
[:app, :docs].each do |repo|
  if node[:boilerplate].key?(repo)
    cmd = case node[:boilerplate][repo]
          when 'git'
            'git clone'
          when 'svn'
            'svn co'
          else
            'git clone'
          end
    dest = "#{node[:boilerplate][:document_root]}/#{repo}"
    execute "clone #{repo} into #{dest}" do
      command "cd #{node[:boilerplate][:document_root]}; #{cmd} #{node[:boilerplate][repo][:uri]} #{repo}"
      not_if { ::File.exist?("#{dest}") }
    end
    directory dest do
      owner 'www-data'
      group 'www-data'
    end
  end
end

# Install gem packages
execute 'install bundler' do
  command 'gem i bundler'
end

execute 'install gem packages' do
  command "cd #{node[:boilerplate][:app_root]}; bundle"
  only_if { ::File.exist?("#{node[:boilerplate][:app_root]}/Gemfile") }
end

%w( yui_compressor jslint closure_compiler ).each do |package|
  execute "juicer install #{package}" do
    command "juicer install #{package}"
    only_if { ::File.exist?("#{node[:boilerplate][:app_root]}/Gemfile") }
    not_if { ::File.exist?("#{ENV['HOME']}/.juicer/lib/#{package}") }
  end
end

# Install npm packages
case node[:platform]
when 'ubuntu'
  package 'nodejs'
  execute 'install npm packages' do
    command 'npm -g install jshint grunt-cli gfms bower'
  end
else
  include_recipe 'node'
  include_recipe 'nodejs::install_from_binary'
  %w( jshint grunt-cli gfms bower ).each do |package|
    node_npm package do
      action :install
    end
  end
end

# Change git protocol
execute 'change git protocol' do
  command 'git config --global url.\'https://\'.insteadOf git://'
  only_if { node[:boilerplate][:git][:use_git_protocol] == false }
end

# Install bower packages
execute 'install bower packages' do
  command 'bower install --allow-root'
  cwd node[:boilerplate][:app_root]
end

## Setup redmine
if node[:boilerplate].key?(:redmine) && node[:boilerplate][:redmine]
  package 'redmine'
  package 'libapache2-mod-passenger'
  execute 'ln -sf /usr/share/redmine/public /var/www/redmine' do
    command 'ln -sf /usr/share/redmine/public /var/www/redmine'
    not_if { ::File.exist?("#{node[:boilerplate][:docs_root]}/redmine") }
  end
  execute 'update alternatives' do
    command 'update-alternatives --set ruby /usr/bin/ruby1.9.1; update-alternatives --set gem /usr/bin/gem1.9.1;'
  end
end

## Setup jenkins
if node[:boilerplate].key?(:jenkins) && node[:boilerplate][:jenkins]
  include_recipe 'jenkins::master'

  group 'jenkins' do
    action [:create, :modify]
    members 'jenkins'
    append true
  end

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

## Setup apache
include_recipe 'apache2'

%w( proxy proxy_http ).each do |m|
  apache_module m do
    enable true
  end
end

%w( app jenkins redmine ).each do |site|
  next unless node[:boilerplate][site]
  template "#{node[:apache][:dir]}/sites-available/#{site}" do
    source "apache2/#{site}.erb"
    notifies :restart, 'service[apache2]'
  end
  apache_site site do
    enable true
  end
end

template "#{node[:apache][:dir]}/conf.d/boilerplate" do
  source 'apache2/boilerplate.erb'
  notifies :restart, 'service[apache2]'
end

## Setup mysql
include_recipe 'database::mysql'
include_recipe 'mysql::server'

mysql_connection_info = {
  :host => 'localhost',
  :username => 'root',
  :password => node[:mysql][:server_root_password]
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

## Setup gitlab
if node[:boilerplate][:gitlab]
  # Workaround for the issue default site port can't be changed
  # @see https://github.com/opscode-cookbooks/nginx/pull/201
  node.default[:nginx][:default_site_enabled] = false
  node.default[:gitlab][:listen_port] = node[:boilerplate][:gitlab][:port]
  include_recipe 'gitlab'
end

# Add additional permissions for vagrant
%w( www-data ).each do |group|
  group group do
    action :modify
    members 'vagrant'
    append true
    only_if 'grep vagrant /etc/passwd'
  end
end
