#
# Author:: Kyle Bader <kyle.bader@dreamhost.com>
# Cookbook Name:: ceph_test
# Recipe:: radosgw_zone
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

ceph_radosgw 'us-test' do
  region 'default'
  zone 'default'
  region_root_pool '.rgw.root'
  zone_root_pool '.rgw.root'
  dns_name 'ceph.test'
  dns_aliases ['*.ceph.test']
  keyname 'client.radosgw.us-test'
  socket_path '/var/run/ceph-radosgw/radosgw.us-test'
  print_continue true
end.run_action(:add)

package 'curl'   # used for the tests
