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

ceph_rbd 'rbd_test' do
  action :attach
end

ceph_rbd 'full_test' do
  action :create
  size '128'
end

ceph_rbd 'full_test' do
  action :attach
end

ceph_rbd 'full_test' do
  action :detach
end

ceph_rbd 'full_test' do
  action :delete
end
