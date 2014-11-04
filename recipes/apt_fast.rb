# -*- coding: utf-8 -*-
#
# Cookbook Name:: boilerplate
# Recipe:: apt_fast
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

case node[:platform]
when 'debian'
  package 'apt-spy'

  execute 'choose fastest mirror' do
    command "apt-spy -s #{node[:boilerplate][:country]} -d stable"
    not_if { ::File.exist?('/etc/apt/sources.list.d/apt-spy.list') }
    notifies :run, 'execute[apt-get update]', :immediately
  end
when 'ubuntu'
  execute 'choose fastest mirror' do
    command "sed -i 's/us.archive/#{node[:boilerplate][:country]}.archive/g' /etc/apt/sources.list"
  end

  # Add apt-fast
  apt_repository 'apt-fast' do
    uri 'ppa:apt-fast/stable'
    distribution node[:lsb][:codename]
    notifies :run, 'execute[apt-get update]', :immediately
  end
  package 'apt-fast'
  package 'aria2'
  node.set[:boilerplate][:apt_command] = 'apt-fast'
  template '/etc/apt-fast.conf' do
    source 'apt-fast/apt-fast.conf.erb'
    notifies :run, 'execute[apt-get update]', :immediately
  end
end
