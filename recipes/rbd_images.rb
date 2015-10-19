#
# Cookbook Name:: ceph
# Provider:: rbd
#
# Authors:: Sandor Acs <acs.sandor@ustream.tv>, Krisztian Gacsal <gacsal.krisztian@ustream.tv>
#

id = "rbd.#{node['hostname']}"
filename = "/etc/ceph/ceph.client.#{id}.secret"

ceph_client 'rbd' do
  filename filename
  caps('mon' => 'allow r', 'osd' => 'allow * pool=rbd')
end

if node['ceph']['user_rbd_images']
  node['ceph']['user_rbd_images'].each do |image|
    # Create user-defined images
    ceph_rbd image['name'] do
      size image['size']
      id id
      keyring filename
      action :create
    end
  end
end
