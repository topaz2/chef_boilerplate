# -*- coding: utf-8 -*-
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

node[:boilerplate][:recipes].each do |recipe|
  include_recipe "boilerplate::#{recipe}" if node[:boilerplate][recipe.to_sym]
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
