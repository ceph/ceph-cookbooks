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
      attach_rbd_image(@new_resource.pool, @new_resource.name, @new_resource.id, @new_resource.keyring)
    end
  end
end

action :detach do
  if ! @current_resource.attached
    Chef::Log.info "#{@new_resource} does not attached - nothing to do."
  else
    converge_by("Detach RBD: #{@new_resource.name}") do
      detach_rbd_image(@new_resource.pool, @new_resource.name, @new_resource.id, @new_resource.keyring)
    end
  end
end

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already created - nothing to do."
  else
    converge_by("Create RBD: #{@new_resource.name}") do
      create_rbd_image(@new_resource.pool, @new_resource.name, @new_resource.size, @new_resource.id, @new_resource.keyring)
    end
  end
end

action :delete do
  if ! @current_resource.exists
    Chef::Log.info "#{@new_resource} does not exist - nothing to do."
  else
    converge_by("Delete RBD: #{@new_resource.name}") do
      delete_rbd_image(@new_resource.pool, @new_resource.name, @new_resource.id, @new_resource.keyring)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::CephRbd.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.pool(@new_resource.pool)
  @current_resource.id(@new_resource.id)
  @current_resource.keyring(@new_resource.keyring)
  @current_resource.size(@new_resource.size)
  @current_resource.exists = rbd_exists?(@current_resource.pool, @current_resource.name, @current_resource.id, @current_resource.keyring)
  @current_resource.attached = rbd_attached?(@current_resource.pool, @current_resource.name, @current_resource.id, @current_resource.keyring)
end

def rbd_exists?(pool, image, id, keyring)
  cmd = Mixlib::ShellOut.new("rbd info #{pool}/#{image} --id #{id} --keyring=#{keyring}")
  cmd.run_command
  cmd.error!
  Chef::Log.debug "RBD exists: #{cmd.stdout}"
  true
rescue
  Chef::Log.debug "RBD doesn't seem to exist: #{cmd.stderr}"
  false
end

def rbd_attached?(pool, image, id, keyring)
  cmd = Mixlib::ShellOut.new("rbd showmapped --id #{id} --keyring=#{keyring}|grep '#{pool}  #{image}'")
  cmd.run_command
  cmd.error!
  Chef::Log.debug "RBD attached: #{cmd.stdout}"
  true
rescue
  Chef::Log.debug "RBD doesn't seem to exist: #{cmd.stderr}"
  false
end

def attach_rbd_image(pool, image, id, keyring)
  ruby_block 'Add RBD to rbdmap' do
    block do
      rc = Chef::Util::FileEdit.new('/etc/ceph/rbdmap')
      rc.insert_line_if_no_match(%r{#{pool}\/#{image}\tid=#{id},keyring=#{keyring}}, "%r{#{pool}/#{image}\tid=#{id},keyring=#{keyring}}")
      rc.write_file
    end
    only_if { rbd_exists?(pool, image, id, keyring) }
  end

  execute 'attach_rbd' do
    command "rbd map #{pool}/#{image} --id #{id} --keyring #{keyring}"
    only_if { rbd_exists?(pool, image, id, keyring) }
  end
end

def detach_rbd_image(pool, image, id, keyring)
  execute 'detach_rbd' do
    command "rbd unmap /dev/rbd/#{pool}/#{image} --id #{id} --keyring=#{keyring}"
  end

  ruby_block 'Remove RBD from rbdmap' do
    block do
      rc = Chef::Util::FileEdit.new('/etc/ceph/rbdmap')
      rc.search_file_delete_line(%r{#{pool}\/#{image}\tid=#{id},keyring=#{keyring}})
      rc.write_file
    end
  end
end

def create_rbd_image(pool, image, size,  id, keyring)
  cmd_text = "rbd create #{image} --size #{size} --pool #{pool} --id #{id} --keyring=#{keyring}"
  cmd = Mixlib::ShellOut.new(cmd_text)
  cmd.run_command
  cmd.error!
  Chef::Log.debug "RBD image created: #{cmd.stdout}"
end

def delete_rbd_image(pool, image, id, keyring)
  cmd_text = "rbd rm #{image} --pool #{pool} --id #{id} --keyring=#{keyring}"
  cmd = Mixlib::ShellOut.new(cmd_text)
  cmd.run_command
  cmd.error!
  Chef::Log.debug "RBD image deleted: #{cmd.stdout}"
end
