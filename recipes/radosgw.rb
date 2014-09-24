#
# Author:: Kyle Bader <kyle.bader@dreamhost.com>
# Cookbook Name:: ceph
# Recipe:: radosgw
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

node.default['ceph']['is_radosgw'] = true

include_recipe 'ceph::_common'
include_recipe 'ceph::radosgw_install'
include_recipe 'ceph::conf'

directory '/var/log/radosgw' do
  owner node['apache']['user']
  group node['apache']['group']
  mode '0755'
  action :create
end

file '/var/log/radosgw/radosgw.log' do
  owner node['apache']['user']
  group node['apache']['group']
end

directory '/var/run/ceph-radosgw' do
  owner node['apache']['user']
  group node['apache']['group']
  mode '0755'
  action :create
end

if !::File.exist?("/var/lib/ceph/radosgw/ceph-radosgw.#{node['hostname']}/done")
  if node['ceph']['radosgw']['webserver_companion']
    include_recipe "ceph::radosgw_#{node['ceph']['radosgw']['webserver_companion']}"
  end

  ceph_client 'radosgw' do
    caps('mon' => 'allow rw', 'osd' => 'allow rwx')
    owner 'root'
    group node['apache']['group']
    mode 0640
  end

  directory "/var/lib/ceph/radosgw/ceph-radosgw.#{node['hostname']}" do
    recursive true
  end
  ceph_client 'radosgw keyring' do
    keyname "client.radosgw.#{node['hostname']}"
    filename "/var/lib/ceph/radosgw/ceph-radosgw.#{node['hostname']}/keyring"
    caps('mon' => 'allow rw', 'osd' => 'allow rwx')
  end

  file "/var/lib/ceph/radosgw/ceph-radosgw.#{node['hostname']}/done" do
    action :create
  end

  service 'radosgw' do
    case node['ceph']['radosgw']['init_style']
    when 'upstart'
      service_name 'radosgw-all-starter'
      provider Chef::Provider::Service::Upstart
    else
      if node['platform'] == 'debian'
        service_name 'radosgw'
      else
        service_name 'ceph-radosgw'
      end
    end
    supports :restart => true
    action [:enable, :start]
    subscribes :restart, 'template[/etc/ceph/ceph.conf]'
  end
else
  Log.info('Rados Gateway already deployed')
end
