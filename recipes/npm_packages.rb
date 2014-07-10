# -*- coding: utf-8 -*-
#
# Cookbook Name:: boilerplate
# Recipe:: npm_packages
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
when 'ubuntu'
  package 'nodejs'
when 'debian'
  # include_recipe 'node'
  # include_recipe 'nodejs::install_from_source'
  include_recipe 'nodejs::install_from_package'
else
  # include_recipe 'node'
  include_recipe 'nodejs::install_from_binary'
end

%w(
  jshint grunt-cli gfms bower
  karma karma-coverage karma-jasmine
  karma-firefox-launcher karma-chrome-launcher karma-phantomjs-launcher
  jasmine-jquery
).each do |package|
  node_npm package do
    action :install
  end
end
include_recipe 'phantomjs'
