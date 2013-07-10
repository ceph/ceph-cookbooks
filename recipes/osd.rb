#
# Author:: Kyle Bader <kyle.bader@dreamhost.com>
# Cookbook Name:: ceph
# Recipe:: osd
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

# this recipe allows bootstrapping new osds, with help from mon

include_recipe "ceph::default"
include_recipe "ceph::conf"

package 'gdisk' do
  action :upgrade
end

mons = get_mon_nodes(node['ceph']['config']['environment'])
have_mons = !mons.empty?
mons = get_mon_nodes(node['ceph']['config']['environment'], "ceph_bootstrap_osd_key:*")

if not have_mons then
  Chef::Log.info("No ceph-mon found.")
else

  while mons.empty?
    sleep(1)
    mons = get_mon_nodes(node['ceph']['config']['environment'], "ceph_bootstrap_osd_key:*")
  end # while mons.empty?

  directory "/var/lib/ceph/bootstrap-osd" do
    owner "root"
    group "root"
    mode "0755"
  end

  # TODO cluster name
  cluster = 'ceph'

  execute "format as keyring" do
    command <<-EOH
      set -e
      # TODO don't put the key in "ps" output, stdout
      ceph-authtool '/var/lib/ceph/bootstrap-osd/#{cluster}.keyring' --create-keyring --name=client.bootstrap-osd --add-key='#{mons[0]["ceph_bootstrap_osd_key"]}'
      rm -f '/var/lib/ceph/bootstrap-osd/#{cluster}.keyring.raw'
    EOH
    creates "/var/lib/ceph/bootstrap-osd/#{cluster}.keyring"
  end

  if is_crowbar?
    ruby_block "select new disks for ceph osd" do
      block do
        do_trigger = false
        node["crowbar"]["disks"].each do |disk, data|

          already_prepared = false
          if not node["crowbar_wall"].nil? and not node["crowbar_wall"]["ceph"].nil? and not node["crowbar_wall"]["ceph"][disk].nil? and not node["crowbar_wall"]["ceph"][disk]["prepared"].nil?
            already_prepared = true unless node["crowbar_wall"]["ceph"][disk]["prepared"] == false
          end

          if node["crowbar"]["disks"][disk]["usage"] == "Storage" and not already_prepared
            Chef::Log.debug("Disk: #{disk} should be used for ceph")

            #When executing the barclamp on a raw disk ceph-disk-prepare fails
            #We first need to create the GUID Partition Table
            #Then create an initial partition and verify it works
            unless ::Kernel.system("grep -q \'#{disk}1$\' /proc/partitions")
              Chef::Log.info("Preparing #{disk} with GPT.")
              ::Kernel.system("sgdisk /dev/#{disk}")
              Chef::Log.info("Creating initial partition on #{disk} as needed.")
              ::Kernel.system("parted -s /dev/#{disk} -- unit s mklabel gpt mkpart ext2 2048s -1M")
              ::Kernel.system("partprobe /dev/#{disk}")
              sleep 3
              ::Kernel.system("dd if=/dev/zero of=/dev/#{disk}1 bs=1024 count=65")
            end

            system 'ceph-disk-prepare', \
              "/dev/#{disk}"
            raise 'ceph-disk-prepare failed' unless $?.exitstatus == 0

            do_trigger = true

            node["crowbar_wall"]["ceph"] = {} unless node["crowbar_wall"]["ceph"]
            node["crowbar_wall"]["ceph"][disk] = {} unless node["crowbar_wall"]["ceph"][disk]
            node["crowbar_wall"]["ceph"][disk]["prepared"] = true
            node.save
          end
        end

        if do_trigger
          system 'udevadm', \
            "trigger", \
            "--subsystem-match=block", \
            "--action=add"
          raise 'udevadm trigger failed' unless $?.exitstatus == 0
        end

      end
    end
  end
end
