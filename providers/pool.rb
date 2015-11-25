#
# Cookbook Name:: ceph
# Provider:: pool
#
# Author:: Sergio de Carvalho <scarvalhojr@users.noreply.github.com>
#

def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if @current_resource.exists
    if @current_resource.pg_num == @new_resource.pg_num
      Chef::Log.info "#{@new_resource} already exists - nothing to do."
    else
      Chef::Log.info "#{@new_resource} already exists, with different pg_num."
      converge_by("Setting pg_num for #{@new_resource}") do
        set_pg_num(@new_resource.name, @new_resource.pg_num)
        while get_pgp_num(@new_resource.name) != @new_resource.pg_num
          set_pgp_num(@new_resource.name, @new_resource.pg_num)
        end
      end
    end
  else
    converge_by("Creating #{@new_resource}") do
      create_pool
    end
  end
end

action :delete do
  if @current_resource.exists
    converge_by("Deleting #{@new_resource}") do
      delete_pool
    end
  else
    Chef::Log.info "#{@current_resource} does not exist - nothing to do."
  end
end

def load_current_resource
  @current_resource = Chef::Resource::CephPool.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.exists = pool_exists?(@current_resource.name)
  @current_resource.pg_num = get_pg_num(@current_resource.name) || 0
  @current_resource.pgp_num = get_pgp_num(@current_resource.name) || 0
end

def create_pool
  cmd_text = "ceph osd pool create #{new_resource.name} #{new_resource.pg_num}"
  cmd_text << " #{new_resource.create_options}" if new_resource.create_options
  cmd = Mixlib::ShellOut.new(cmd_text)
  cmd.run_command
  cmd.error!
  Chef::Log.debug "Pool created: #{cmd.stderr}"
end

def delete_pool
  cmd_text = "ceph osd pool delete #{new_resource.name}"
  cmd_text << " #{new_resource.name} --yes-i-really-really-mean-it" if
    new_resource.force
  cmd = Mixlib::ShellOut.new(cmd_text)
  cmd.run_command
  cmd.error!
  Chef::Log.debug "Pool deleted: #{cmd.stderr}"
end

def set_pg_num(name, pg_num)
  cmd_text = "ceph osd pool set #{name} pg_num #{pg_num}"
  cmd = Mixlib::ShellOut.new(cmd_text)
  cmd.run_command
  cmd.error!
  Chef::Log.debug "Placement Groups Set: #{cmd.stderr}"
end

def set_pgp_num(name, pg_num)
  cmd_text = "ceph osd pool set #{name} pgp_num #{pg_num}"
  cmd = Mixlib::ShellOut.new(cmd_text)
  cmd.run_command
  cmd.error!
  Chef::Log.debug "Placement Groups Set: #{cmd.stderr}"
end

def get_pg_num(name)
  cmd = Mixlib::ShellOut.new("ceph osd pool get #{name} pg_num")
  cmd.run_command
  cmd.error!
  cmd.stdout.split(' ')[1].to_i
end

def get_pgp_num(name)
  cmd = Mixlib::ShellOut.new("ceph osd pool get #{name} pgp_num")
  cmd.run_command
  cmd.error!
  cmd.stdout.split(' ')[1].to_i
end

def pool_exists?(name)
  cmd = Mixlib::ShellOut.new("ceph osd pool get #{name} size")
  cmd.run_command
  cmd.error!
  Chef::Log.debug "Pool exists: #{cmd.stdout}"
  true
rescue
  Chef::Log.debug "Pool doesn't seem to exist: #{cmd.stderr}"
  false
end
