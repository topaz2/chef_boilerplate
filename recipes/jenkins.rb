# -*- coding: utf-8 -*-
#
# Cookbook Name:: boilerplate
# Recipe:: jenkins
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

include_recipe 'jenkins::master'

group 'jenkins' do
  action [:create, :modify]
  members 'jenkins'
  append true
end

template '/etc/default/jenkins' do
  source 'default/jenkins.erb'
  notifies :restart, 'service[jenkins]'
end

require 'chef-helpers'

jobs = []
%w(
  development staging production
).each do |environment|
  %w(
    app_build app_cookbook app_deploy app_docs app_package app_vagrant boilerplate
  ).each do |type|
    log environment
    log type
    jobs << [environment, type].join('_')
  end
end
jobs.each do |job|
  next unless has_template?("jenkins/jobs/#{job}/config.xml.erb")

  xml = File.join(Chef::Config[:file_cache_path], "jenkins-jobs-#{job}-config.xml")
  template xml do
    source "jenkins/jobs/#{job}/config.xml.erb"
  end

  jenkins_job job do
    config xml
    not_if { ::File.exist?("#{node[:jenkins][:master][:home]}/jobs/#{job}/config.xml") }
  end

  template "#{node[:jenkins][:master][:home]}/jobs/#{job}/config.xml" do
    source "jenkins/jobs/#{job}/config.xml.erb"
  end
end

template "#{node[:jenkins][:master][:home]}/config.xml" do
  source 'jenkins/config.xml.erb'
  notifies :restart, 'service[jenkins]'
end

template "#{node[:jenkins][:master][:home]}/jenkins.model.JenkinsLocationConfiguration.xml" do
  source 'jenkins/jenkins.model.JenkinsLocationConfiguration.xml.erb'
  notifies :restart, 'service[jenkins]'
end

remote_directory '/usr/local/bin/tools/build/jenkins' do
  files_mode 0755
  source 'tools/build/jenkins'
end

%w(
  credentials ghprb git-client git github-api github scm-api ssh-credentials anything-goes-formatter
  ansicolor build-pipeline-plugin extra-columns jobConfigHistory
).each do |p|
  jenkins_plugin p
end
