# -*- coding: utf-8 -*-
#
# Cookbook Name:: boilerplate
# Recipe:: mysql
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

mysql_connection_info = {
  host: 'localhost',
  username: 'root',
  password: node[:mysql][:server_root_password]
}

mysql_database_user 'test' do
  connection mysql_connection_info
  password 'test'
  action :grant
end unless node.chef_environment == 'production'

mysql_database_user 'slave' do
  connection mysql_connection_info
  password 'slave'
  host '%'
  privileges [:select]
  action :grant
end

environment = node.chef_environment == '_default' ? 'development' : node.chef_environment
if node[:mysql][:role]
  template '/etc/mysql/conf.d/my.cnf' do
    source "mysql/#{node[:mysql][:role]}/my.cnf.#{environment}.erb"
    notifies :restart, 'mysql_service[default]'
  end
else
  template '/etc/mysql/conf.d/my.cnf' do
    source "mysql/slave/my.cnf.#{environment}.erb"
    notifies :restart, 'mysql_service[default]'
  end
end
