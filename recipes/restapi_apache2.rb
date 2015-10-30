#
# Author:: Kyle Bader <kyle.bader@dreamhost.com>
# Cookbook Name:: ceph
# Recipe:: restapi_apache2
#
# Copyright 2011, DreamHost Web Hosting
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# For EL, delete the current fastcgi configuration
# and set the correct owners for dirs and logs
d_owner = d_group = 'root'
d_owner = d_group = 'apache' if node['platform_family'] == 'rhel'
node.default['ceph']['restapi']['user'] = node['apache']['user']
node.default['ceph']['restapi']['group'] = node['apache']['group']

template '/usr/lib/ceph/restapi.wsgi' do
  mode 0644
  owner 'root'
  group 'root'
end

file '/var/log/ceph/rest.log' do
  owner d_owner
  group d_group
  mode '0644'
  action :create
end

if node['ceph']['restapi']['port']
  node.default['apache']['listen_ports'].push(node['ceph']['restapi']['port'])
end

include_recipe 'apache2'
include_recipe 'apache2::mod_wsgi'

web_app 'restapi' do
  template 'restapi.conf.erb'
end
