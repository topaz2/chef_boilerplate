# -*- coding: utf-8 -*-
#
# Cookbook Name:: boilerplate
# Recipe:: apt_packages
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
  apt_repository 'emacs' do
    uri 'ppa:cassou/emacs'
    distribution node[:lsb][:codename]
  end
  packages.push('emacs24')
end

# Install packages necessary for this project
packages.concat(node[:boilerplate][:install_packages])

dependencies = []
packages.each do |pkg|
  if node.default[:versions][pkg].is_a? String
    dependencies << [pkg, node.default[:versions][pkg]].join('=')
  else
    dependencies << pkg
  end
end

execute 'apt-get install' do
  command "export DEBIAN_FRONTEND=noninteractive && #{node[:boilerplate][:apt_command]} -q -y install #{dependencies.join(' ')}"
end

# packages.each do |pkg|
#   package pkg do
#     action [:install, :upgrade]
#     version node[:versions][pkg] if node[:versions][pkg].is_a? String
#   end
# end
