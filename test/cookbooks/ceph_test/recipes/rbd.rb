#
# Cookbook Name:: ceph
# Provider:: rbd
#
# Authors:: Sandor Acs <acs.sandor@ustream.tv>, Krisztian Gacsal <gacsal.krisztian@ustream.tv>
#

execute 'start rbd kernel module' do
  command 'modprobe rbd'
  user 'root'
  group 'root'
end

include_recipe 'ceph::rbd_images'

id = "rbd.#{node['hostname']}"
filename = "/etc/ceph/ceph.client.#{id}.secret"

ceph_rbd 'rbd_test' do
  id id
  keyring filename
  action :attach
end

ceph_rbd 'full_test' do
  size '128'
  id id
  keyring filename
  action :create
end

ceph_rbd 'full_test' do
  id id
  keyring filename
  action :attach
end

ceph_rbd 'full_test' do
  id id
  keyring filename
  action :detach
end

ceph_rbd 'full_test' do
  id id
  keyring filename
  action :delete
end
