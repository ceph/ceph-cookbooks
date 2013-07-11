#
# Cookbook Name:: ceph
# Provider:: pool
#
# Author:: Hunter Nield <hunter@acale.ph>
#
# Copyright 2013, Hunter Nield
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

def whyrun_supported?
  true
end

action :create do
  converge_by("Creating pool '#{new_resource.name}'") do
    execute "create pool" do
      not_if "rados lspools | grep #{new_resource.name}"
      command("rados mkpool #{new_resource.name}")
    end
    Chef::Log.info("Created` pool '#{new_resource.name}'")
  end
end

action :delete do
  
  converge_by("Deleting pool '#{new_resource.name}'") do
    execute "delete pool" do
      only_if "rados lspools | grep #{new_resource.name}"
      if new_resource.force == true
        command("rados rmpool #{new_resource.name} #{new_resource.name} --yes-i-really-really-mean-it")
      else
        command("rados rmpool #{new_resource.name}")
      end
      Chef::Log.info("Deleted pool '#{new_resource.name}'")
    end
  end
end