#
# Author:: Kyle Bader <kyle.bader@dreamhost.com>
# Cookbook Name:: ceph
# Recipe:: restapi
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

node.default['ceph']['is_restapi'] = true

include_recipe 'ceph::conf'

if node['ceph']['restapi']['webserver_companion']
  # updates the webserver owner
  include_recipe "ceph::restapi_#{node['ceph']['restapi']['webserver_companion']}"
end

config_section_name = 'client.restapi.' + node['hostname']
config_section = { 'log_file' => '/var/log/ceph/restapi/restapi.log' }
node.default['ceph']['config-sections'][config_section_name] = config_section

directory '/var/log/ceph/restapi' do
  owner node['ceph']['restapi']['user']
  group node['ceph']['restapi']['group']
  mode 0755
  action :create
end
ceph_client 'restapi' do
  caps('mon' => 'allow *', 'osd' => 'allow *')
  owner node['ceph']['restapi']['user']
  group node['ceph']['restapi']['group']
end
