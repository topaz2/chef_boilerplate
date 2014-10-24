# -*- coding: utf-8 -*-
#
# Cookbook Name:: boilerplate
# Recipe:: apache2
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

## Setup apache
%w( proxy proxy_http ).each do |m|
  apache_module m do
    enable true
  end
end

%w( app redmine ).each do |site|
  next unless node[:boilerplate][site]
  template "#{node[:apache][:dir]}/sites-available/#{site}.conf" do
    source "apache2/#{site}.conf.erb"
    notifies :restart, 'service[apache2]'
  end
  apache_site site do
    enable true
  end
end

template "#{node[:apache][:dir]}/conf-available/boilerplate.conf" do
  source 'apache2/boilerplate.conf.erb'
  notifies :restart, 'service[apache2]'
end
apache_config 'boilerplate' do
  enable true
end
