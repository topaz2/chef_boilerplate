# -*- coding: utf-8 -*-
#
# Cookbook Name:: boilerplate
# Recipe:: gem_packages
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

execute 'install bundler' do
  command 'gem i bundler'
end

execute 'install gem packages' do
  command "cd #{node[:boilerplate][:app_root]}; bundle install --full-index --jobs=`ohai cpu/total`"
  only_if { ::File.exist?("#{node[:boilerplate][:app_root]}/Gemfile") }
end

%w( jslint closure_compiler ).each do |package|
  execute "juicer install #{package}" do
    command "juicer install #{package}"
    only_if { ::File.exist?("#{node[:boilerplate][:app_root]}/Gemfile") }
    not_if { ::File.exist?("#{ENV['HOME']}/.juicer/lib/#{package}") }
  end
end

%w( knife-solo ).each do |package|
  chef_gem package
end
