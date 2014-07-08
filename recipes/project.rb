# -*- coding: utf-8 -*-
#
# Cookbook Name:: boilerplate
# Recipe:: project
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

# Clone project from repository
[:app, :docs].each do |type|
  next unless node[:boilerplate][type][:repo][:uri]
  cmd = case node[:boilerplate][type][:repo][:type]
        when 'git'
          'git clone'
        when 'svn'
          'svn co'
        else
          'git clone'
        end
  dest = "#{node[:boilerplate][:document_root]}/#{type}"
  execute "clone #{type} into #{dest}" do
    command "cd #{node[:boilerplate][:document_root]}; #{cmd} #{node[:boilerplate][type][:repo][:uri]} #{type}"
    not_if { ::File.exist?(dest) }
  end
  directory dest do
    owner 'www-data'
    group 'www-data'
    recursive true
  end
end
