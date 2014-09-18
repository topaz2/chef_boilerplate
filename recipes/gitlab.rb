# -*- coding: utf-8 -*-
#
# Cookbook Name:: boilerplate
# Recipe:: gitlab
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

# Workaround for the issue default site port can't be changed
# @see https://github.com/opscode-cookbooks/nginx/pull/201
node.default[:nginx][:default_site_enabled] = false
node.default[:gitlab][:listen_port] = node[:boilerplate][:gitlab][:port]
include_recipe 'redisio'
include_recipe 'gitlab'
