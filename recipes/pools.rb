#
# Cookbook Name:: ceph
# Recipe:: pools
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

# This recipe uses a LWRP to setup pools defined in the environment

if !node["ceph"]["pools"].nil?
  node["ceph"]["pools"].each do |pool|
    Log.debug("ceph-pool: #{pool}")
    ceph_manage_pool pool["name"] do
      pg_num pool["pg_num"]
      pgp_num pool["pgp_num"]
      min_size pool["min_size"]
      action :create
      not_if "ceph osd lspools | grep #{pool["name"]}"
    end
  end
end
