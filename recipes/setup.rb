#
# Cookbook Name:: ceph
# Recipe:: setup
#
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
#

# make sure we die early if there is another ceph-setup node
search_query = "roles:ceph-setup NOT name:#{node.name}"
search_result = search(:node, search_query)
if search_result.length > 0
  msg = "You can only have one node with the ceph-setup role."
  Chef::Application.fatal! msg
end

# This recipe creates a new ceph cluster and sets the node up as the
# mon_initial_member for the cluster. This value can be overridden if
# desired.

if node['ceph']['config']['fsid'].nil?
  Log.info("ceph-setup: ceph fsid not set - generating a new fsid")
  fsid = Mixlib::ShellOut.new("uuidgen").run_command.stdout.strip
  node.set['ceph']['config']['fsid'] = fsid
  node.save
  Log.info("ceph-setup: ceph fsid has been set to #{fsid}")
else
  Log.info("ceph-setup: ceph fsid is #{node['ceph']['config']['fsid']}")
end

if node['ceph']['config']['mon_initial_members'].nil?
  Log.info("ceph-setup: mon_initial_members not set - using the ceph-setup node")
  node.set['ceph']['config']['mon_initial_members'] = node['hostname']
  node.save
  Log.info("ceph-setup: mon_initial_members has been set to #{node['hostname']}")
else
  Log.info("ceph-setup: mon_initial_members is #{node['ceph']['config']['mon_initial_members']}")
end

include_recipe "ceph::default"
