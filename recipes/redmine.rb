# -*- coding: utf-8 -*-
#
# Cookbook Name:: boilerplate
# Recipe:: redmine
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

# Setup redmine server
package 'redmine'
package 'libapache2-mod-passenger'
apache_module 'passenger'
execute 'ln -sf /usr/share/redmine/public /var/www/redmine' do
  command 'ln -sf /usr/share/redmine/public /var/www/redmine'
  not_if { ::File.exist?("#{node[:boilerplate][:docs_root]}/redmine") }
end
execute 'update alternatives' do
  command 'update-alternatives --set ruby /usr/bin/ruby1.9.1; update-alternatives --set gem /usr/bin/gem1.9.1;'
end

# Setup backup scripts
{
  archive_local: '10_backup_redmine_local',
  archive_remote: '30_backup_redmine_remote',
  purge: '20_purge_redmine_backup'
}.each do |type, script|
  template "/etc/#{node[:boilerplate][:backup][:schedule][type][:strategy]}/#{script}" do
    source "cron/#{script}.erb"
    mode '0755'
  end if node[:boilerplate][:backup][:schedule][type]
end
