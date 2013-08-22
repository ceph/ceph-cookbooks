#
# Author:: Jesse Pretorius <jesse.pretorius@bcx.co.za>
# Cookbook Name:: ceph
# Provider:: manage_pool
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

action :create do
  name     = new_resource.name
  pg_num   = new_resource.pg_num
  pgp_num  = new_resource.pgp_num
  min_size = new_resource.min_size

  if pgp_num.nil?
    Log.debug("Setting ceph-pool #{name} pgp_num to #{pg_num} as no value was provided.")
    pgp_num = new_resource.pg_num
  elsif pgp_num > pg_num
    Log.warn("Setting ceph-pool #{name} pgp_num to #{pg_num} as it cannot be a larger value.")
    pgp_num = new_resource.pg_num
  end

  execute "create ceph pool #{name} with pg_num #{pg_num} and pgp_num #{pgp_num}" do
    command "ceph osd pool create #{name} #{pg_num} #{pgp_num}"
  end

  if min_size.nil?
    Log.debug("Leaving ceph-pool #{name} min_size at the default value.")
  else
    execute "set ceph pool #{name} to min_size #{min_size}" do
      command "ceph osd pool set #{name} min_size #{min_size}"
    end
  end

  new_resource.updated_by_last_action(true)
end
