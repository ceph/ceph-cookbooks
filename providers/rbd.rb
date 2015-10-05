#
# Cookbook Name:: ceph
# Provider:: rbd
#
# Authors:: Sandor Acs <acs.sandor@ustream.tv>, Krisztian Gacsal <gacsal.krisztian@ustream.tv>
#

def whyrun_supported?
  true
end

use_inline_resources

action :attach do
  if @current_resource.attached
    Chef::Log.info "#{@new_resource} already attached - nothing to do."
  else
    converge_by("Attach RBD: #{@new_resource.name}") do
      create_client
      attach_rbd_image(@new_resource.pool, @new_resource.name)
    end
  end
end

action :detach do
  if ! @current_resource.attached
    Chef::Log.info "#{@new_resource} does not attached - nothing to do."
  else
    converge_by("Detach RBD: #{@new_resource.name}") do
      detach_rbd_image(@new_resource.pool, @new_resource.name)
    end
  end
end

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already created - nothing to do."
  else
    converge_by("Create RBD: #{@new_resource.name}") do
      create_client
      create_rbd_image(@new_resource.pool, @new_resource.name, @new_resource.size)
    end
  end
end

action :delete do
  if ! @current_resource.exists
    Chef::Log.info "#{@new_resource} does not exist - nothing to do."
  else
    converge_by("Delete RBD: #{@new_resource.name}") do
      delete_rbd_image(@new_resource.pool, @new_resource.name)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::CephRbd.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.pool(@new_resource.pool)
  @current_resource.size(@new_resource.size)
  @current_resource.exists = rbd_exists?(@current_resource.pool, @current_resource.name)
  @current_resource.attached = rbd_attached?(@current_resource.pool, @current_resource.name)
end

def rbd_exists?(pool, image)
  cmd = Mixlib::ShellOut.new("rbd info #{pool}/#{image}")
  cmd.run_command
  cmd.error!
  Chef::Log.debug "RBD exists: #{cmd.stdout}"
  true
rescue
  Chef::Log.debug "RBD doesn't seem to exist: #{cmd.stderr}"
  false
end

def rbd_attached?(pool, image)
  id = "rbd.#{node['hostname']}"
  keyring = "/etc/ceph/ceph.client.#{id}.secret"

  cmd = Mixlib::ShellOut.new("rbd showmapped --id #{id} --keyfile #{keyring}|grep '#{pool}  #{image}'")
  cmd.run_command
  cmd.error!
  Chef::Log.debug "RBD attached: #{cmd.stdout}"
  true
rescue
  Chef::Log.debug "RBD doesn't seem to exist: #{cmd.stderr}"
  false
end

def create_client
  id = "rbd.#{node['hostname']}"
  filename = "/etc/ceph/ceph.client.#{id}.secret"

  name = 'rbd'
  ceph_client name do
    filename filename
    caps('mon' => 'allow r', 'osd' => 'allow rw')
    as_keyring false
  end
end

def attach_rbd_image(pool, image)
  id = "rbd.#{node['hostname']}"
  keyring = "/etc/ceph/ceph.client.#{id}.secret"

  ruby_block 'Add RBD to rbdmap' do
    block do
      rc = Chef::Util::FileEdit.new('/etc/ceph/rbdmap')
      rc.insert_line_if_no_match(%r{#{pool}\/#{image}\tid=#{id},keyring=#{keyring}}, "%r{#{pool}/#{image}\tid=#{id},keyring=#{keyring}}")
      rc.write_file
    end
    only_if { rbd_exists?(pool, image) }
  end

  execute 'attach_rbd' do
    command "rbd map #{pool}/#{image}"
    only_if { rbd_exists?(pool, image) }
  end
end

def detach_rbd_image(pool, image)
  id = "rbd.#{node['hostname']}"
  keyring = "/etc/ceph/ceph.client.#{id}.secret"

  execute 'detach_rbd' do
    command "rbd unmap /dev/rbd/#{pool}/#{image} --id #{id} --keyfile #{keyring}"
  end

  ruby_block 'Remove RBD from rbdmap' do
    block do
      rc = Chef::Util::FileEdit.new('/etc/ceph/rbdmap')
      rc.search_file_delete_line(%r{#{pool}\/#{image}\tid=#{id},keyring=#{keyring}})
      rc.write_file
    end
  end
end

def create_rbd_image(pool, image, size)
  id = "rbd.#{node['hostname']}"
  keyring = "/etc/ceph/ceph.client.#{id}.secret"

  cmd_text = "rbd create #{image} --size #{size}  --pool #{pool} --id #{id} --keyfile #{keyring}"
  cmd = Mixlib::ShellOut.new(cmd_text)
  cmd.run_command
  cmd.error!
  Chef::Log.debug "RBD image created: #{cmd.stdout}"
end

def delete_rbd_image(pool, image)
  id = "rbd.#{node['hostname']}"
  keyring = "/etc/ceph/ceph.client.#{id}.secret"

  cmd_text = "rbd rm #{image} --pool #{pool} --id #{id} --keyfile #{keyring}"
  cmd = Mixlib::ShellOut.new(cmd_text)
  cmd.run_command
  cmd.error!
  Chef::Log.debug "RBD image deleted: #{cmd.stdout}"
end
