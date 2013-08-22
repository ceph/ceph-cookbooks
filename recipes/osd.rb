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
# Sample environment:
# #knife node edit ceph1
#"osd_devices": [
#   {
#       "device": "/dev/sdc"
#   },
#   {
#       "device": "/dev/sdd",
#       "dmcrypt": true,
#       "journal": "/dev/sdd"
#   }
#]

include_recipe "ceph::default"
include_recipe "ceph::conf"

if !node["ceph"]["osd_devices"].nil?
  node["ceph"]["osd_devices"].each do |osd_device|
    Log.debug("ceph-osd: #{osd_device}")
  end
elsif node["ceph"]["osd_autoprepare"]
   # set node["ceph"]["osd_autoprepare"] to true to enable automated osd disk
   # discovery and preparation
   osd_devices = Array.new
   node['block_device'].select{|device,info| device =~ /^[hvs]d[^a]$/ and info['size'].to_i > 0}.each do |device,info|
    Log.debug("ceph-osd: Candidate Device /dev/#{device} found.")
    osd_devices << {"device" => "/dev/#{device}"}
  end
  Log.debug("ceph-osd: New Candidates = #{osd_devices}")
  node.set["ceph"]["osd_devices"] = osd_devices
  node.save
else
  Log.warn('ceph-osd: No ceph osd_devices have been set and ceph osd_autoprepare not enabled.')
end

package 'gdisk' do
  action :upgrade
end

# sometimes there are partitions on the disk that interfere with
# ceph-disk-prepare, so let's make sure there's nothing on each candidate disk 
if node["ceph"]["osd_autoprepare"] and !node["ceph"]["osd_devices"].nil?
  node["ceph"]["osd_devices"].each do |osd_device|
    if osd_device['status'].nil?
      ruby_block "ceph-osd: erase #{osd_device['device']} to prepare it as an osd" do
        block do
          devicewipe = Mixlib::ShellOut.new("sgdisk -oZ #{osd_device['device']}").run_command
          if devicewipe.error!
            raise "ceph-osd: erase of #{osd_device['device']} failed!"
          end
        end
      end
    elsif osd_device['status'] == 'deployed'
      Log.debug("ceph-osd: Not erasing #{osd_device['device']} as it has already been deployed.")
    else
      Log.debug("ceph-osd: Not erasing #{osd_device['device']} as it has an unrecognised status.")
    end
  end
end

if !search(:node,"hostname:#{node['hostname']} AND dmcrypt:true").empty?
    package 'cryptsetup' do
      action :upgrade
    end
end

service_type = node["ceph"]["osd"]["init_style"]
mons = get_mon_nodes("bootstrap_osd_key:*")

if mons.empty? then
  Log.warn("ceph-osd: No ceph osd bootstrap key found.")
else

  directory "/var/lib/ceph/bootstrap-osd" do
    owner "root"
    group "root"
    mode "0755"
  end

  # TODO cluster name
  cluster = 'ceph'

  execute "create the local keyring file" do
    command "ceph-authtool '/var/lib/ceph/bootstrap-osd/#{cluster}.keyring' --create-keyring --name=client.bootstrap-osd --add-key='#{mons[0]["ceph"]["bootstrap_osd_key"]}'"
    creates "/var/lib/ceph/bootstrap-osd/#{cluster}.keyring"
  end

  if is_crowbar?
    ruby_block "select new disks for ceph osd" do
      block do
        do_trigger = false
        node["crowbar"]["disks"].each do |disk, data|
          if node["crowbar"]["disks"][disk]["usage"] == "Storage"
            puts "Disk: #{disk} should be used for ceph"

            system 'ceph-disk-prepare', \
              "/dev/#{disk}"
            raise 'ceph-disk-prepare failed' unless $?.exitstatus == 0

            do_trigger = true

            node["crowbar"]["disks"][disk]["usage"] = "ceph-osd"
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
  else
    # Calling ceph-disk-prepare is sufficient for deploying an OSD
    # After ceph-disk-prepare finishes, the new device will be caught
    # by udev which will run ceph-disk-activate on it (udev will map
    # the devices if dm-crypt is used).
    # IMPORTANT:
    #  - Always use the default path for OSD (i.e. /var/lib/ceph/
    # osd/$cluster-$id)
    #  - $cluster should always be ceph
    #  - The --dmcrypt option will be available starting w/ Cuttlefish
    unless node["ceph"]["osd_devices"].nil?
      node["ceph"]["osd_devices"].each_with_index do |osd_device,index|
        if !osd_device["status"].nil?
          Log.debug("ceph-osd: osd_device #{osd_device['device']} has already been prepared.")
          next
        end
        dmcrypt = ""
        if osd_device["encrypted"] == true
          dmcrypt = "--dmcrypt"
        end

        ruby_block "ceph-osd: create osd on #{osd_device['device']}" do
          block do
            deviceprep = Mixlib::ShellOut.new("ceph-disk-prepare #{dmcrypt} #{osd_device['device']} #{osd_device['journal']}").run_command
            if deviceprep.error!
              raise "ceph-osd: osd creation on #{osd_device['device']} failed!"
            else
              node.set["ceph"]["osd_devices"][index]["status"] = "deployed"
              node.save
            end
          end
        end

      end
      service "ceph_osd" do
        case service_type
        when "upstart"
          service_name "ceph-osd-all-starter"
          provider Chef::Provider::Service::Upstart
        else
          service_name "ceph"
        end
        action [ :enable, :start ]
        supports :restart => true
      end
    end
  end
end
