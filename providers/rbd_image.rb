#
# Cookbook Name:: ceph
# Provider:: rbd_image
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
  
  converge_by("Creating block device '#{new_resource.name}' of #{new_resource.size}MB") do
    if new_resource.pool
      pool = "-p #{new_resource.pool}"
    end

    execute "create rbd image" do
      not_if "rbd #{pool} ls | grep #{new_resource.name}"
      command("rbd create #{pool} --size #{new_resource.size} #{new_resource.name}")
    end
    Chef::Log.info("Created block device '#{new_resource.name}' of #{new_resource.size}MB")
  end

end

action :delete do
  
  converge_by("Deleting block device '#{new_resource.name}'") do
    if new_resource.pool
      pool = "-p #{new_resource.pool}"
    end
    
    execute "create rbd image" do
      only_if "rbd #{pool} ls | grep #{new_resource.name}"
      command("rbd rm #{pool} #{new_resource.name}")
    end
    Chef::Log.info("Deleted block device '#{new_resource.name}'")
  end

end

action :map do

  converge_by("Mapping block device '#{new_resource.name}'") do
    if new_resource.pool
      pool = "-p #{new_resource.pool}"
    end

    execute "map rbd image" do
      not_if "rbd #{pool} showmapped | grep #{new_resource.name}"
      command("rbd map #{pool} #{new_resource.name}")
    end
    Chef::Log.info("Mapped block device '#{new_resource.name}'")
  end

end

action :unmap do
  

  converge_by("Unmapping block device '#{new_resource.name}' mounted at '#{new_resource.device}'") do
    if new_resource.pool
      pool = "-p #{new_resource.pool}"
    end

    execute "unmap rbd image" do
      only_if "rbd #{pool} showmapped | grep #{new_resource.device}"
      command("rbd unmap #{pool} #{new_resource.device}")
    end
    Chef::Log.info("Unmapped block device '#{new_resource.name}' mounted at '#{new_resource.device}'")
  end
end
