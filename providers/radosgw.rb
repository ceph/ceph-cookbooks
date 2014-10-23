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

use_inline_resources

def whyrun_supported?
  true
end

action :add do
  node.default['ceph']['is_radosgw'] = true
  region = @new_resource.region
  zone = @new_resource.zone
  ::Chef::Log.info("Saving information for radosgw #{zone}")

  instance = {}
  instance['rgw region'] = @new_resource.region
  instance['rgw region root pool'] = @new_resource.region_root_pool || ".#{region}.rgw.root"
  instance['rgw zone'] = @new_resource.zone
  instance['rgw zone root pool'] = @new_resource.zone_root_pool || ".#{@new_resource.zone}.rgw.root"
  keyname = @new_resource.keyname || "client.radosgw.#{zone}.#{node['hostname']}"
  instance['keyring'] = "/etc/ceph/ceph.#{keyname}.keyring"
  instance['rgw socket path'] = @new_resource.socket_path || "/var/run/ceph-radosgw/radosgw.#{zone}.#{node['hostname']}"
  instance['rgw dns name'] = @new_resource.dns_name
  instance['api_aliases'] = @new_resource.dns_aliases if @new_resource.dns_aliases
  instance['rgw print continue'] = @new_resource.print_continue.to_s unless @new_resource.print_continue.nil?

  node.default['ceph']['radosgw']['instances'][keyname] = instance

end
