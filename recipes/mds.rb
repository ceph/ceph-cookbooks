#
# Author:: Kyle Bader <kyle.bader@dreamhost.com>
# Author:: Jesse Pretorius <jesse.pretorius@bcx.co.za>
# Cookbook Name:: ceph
# Recipe:: mds
#
# Copyright 2011, DreamHost Web Hosting
# Copyright 2013, Business Connexion (Pty) Ltd
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

include_recipe "ceph::default"
include_recipe "ceph::conf"

package 'ceph-mds' do
  action :install
end

service_type = node["ceph"]["mds"]["init_style"]

mons = get_mon_nodes("bootstrap_mds_key:*")

if mons.empty? then
  Log.info("ceph-mds: No ceph mds bootstrap key found.")
else
  mds_bootstrap_directory = "/var/lib/ceph/bootstrap-mds"

  directory "#{mds_bootstrap_directory}" do
    owner "root"
    group "root"
    mode "0755"
  end

  # TODO cluster name
  cluster = 'ceph'

  execute "create the local keyring file" do
    command "ceph-authtool '#{mds_bootstrap_directory}/#{cluster}.keyring' --create-keyring --name=client.bootstrap-mds --add-key='#{mons[0]["ceph"]["bootstrap_mds_key"]}'"
    creates "#{mds_bootstrap_directory}/#{cluster}.keyring"
  end

  mds_directory = "/var/lib/ceph/mds/#{cluster}-#{node['hostname']}"

  directory "#{mds_directory}" do
    owner "root"
    group "root"
    mode "0755"
    recursive true
    action :create
  end

  unless File.exists?("#{mds_directory}/done")
    execute "get or create mds keyring" do
      command "ceph --cluster #{cluster} --name client.bootstrap-mds --keyring #{mds_bootstrap_directory}/#{cluster}.keyring auth get-or-create mds.#{node['hostname']} osd 'allow rwx' mds 'allow' mon 'allow profile mds' -o #{mds_directory}/keyring"
      creates "#{mds_directory}/keyring"
    end
    ruby_block "finalise" do
      block do
        ["done", service_type].each do |ack|
          File.open("#{mds_directory}/#{ack}", "w").close()
        end
      end
    end
  end

  if service_type == "upstart"
    service "ceph-mds" do
      provider Chef::Provider::Service::Upstart
      action :enable
    end
    service "ceph-mds-all" do
      provider Chef::Provider::Service::Upstart
      supports :status => true
      action [ :enable, :start ]
    end
  end

  service "ceph_mds" do
    if service_type == "upstart"
      service_name "ceph-mds-all-starter"
      provider Chef::Provider::Service::Upstart
    else
      service_name "ceph"
    end
    supports :restart => true, :status => true
    action [ :enable, :start ]
  end
end
