# this recipe allows bootstrapping new osds, with help from mon

include_recipe "ceph::osd"
include_recipe "ceph::conf"

package 'gdisk' do
  action :upgrade
end

if is_crowbar?
  mon_roles = search(:role, 'name:crowbar-* AND run_list:role\[ceph-mon\]')
  if not mon_roles.empty?
    search_string = mon_roles.map { |role_object| "role:"+role_object.name }.join(' OR ')
    mons = search(:node, "(#{search_string}) AND ceph_config_environment:#{node['ceph']['config']['environment']} AND ceph_bootstrap_osd_key:*")
  end
else
  mons = search(:node, "role:ceph-mon AND chef_environment:#{node.chef_environment} AND ceph_bootstrap_osd_key:*")
end

if mons.empty? then
  puts "No ceph-mon found."
else

  directory "/var/lib/ceph/bootstrap-osd" do
    owner "root"
    group "root"
    mode "0755"
  end

  # TODO cluster name
  cluster = 'ceph'

  file "/var/lib/ceph/bootstrap-osd/#{cluster}.keyring.raw" do
    owner "root"
    group "root"
    mode "0440"
    content mons[0]["ceph_bootstrap_osd_key"]
  end

  execute "format as keyring" do
    command <<-EOH
      set -e
      # TODO don't put the key in "ps" output, stdout
      read KEY <'/var/lib/ceph/bootstrap-osd/#{cluster}.keyring.raw'
      ceph-authtool '/var/lib/ceph/bootstrap-osd/#{cluster}.keyring' --create-keyring --name=client.bootstrap-osd --add-key="$KEY"
      rm -f '/var/lib/ceph/bootstrap-osd/#{cluster}.keyring.raw'
    EOH
  end

  ruby_block "select new disks for ceph osd" do
    block do
      node["crowbar"]["disks"].each do |disk, data|
        use = true

        if node["swift"]
          node["swift"]["devs"].each do |num|
            if num["name"].match(disk)
              puts "Disk: #{disk} is being used for swift!"
              use = false
            end
          end
        end

        if node["crowbar"]["disks"][disk]["usage"] == "Storage" and use == true
          puts "Disk: #{disk} should be used for ceph!"

          system 'ceph-disk-prepare', \
            "/dev/#{disk}"
          raise 'ceph-disk-prepare failed' unless $?.exitstatus == 0

          system 'udevadm', \
            "trigger", \
            "--subsystem-match=block", \
            "--action=add"
          raise 'udevadm trigger failed' unless $?.exitstatus == 0

          node["crowbar"]["disks"][disk]["usage"] = "ceph-osd"
          node.save
        end
      end
    end
  end
end