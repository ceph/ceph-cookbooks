#
# Cookbook Name:: ceph
# Provider:: rbd
#
# Authors:: Sandor Acs <acs.sandor@ustream.tv>, Krisztian Gacsal <gacsal.krisztian@ustream.tv>
#
actions :attach, :detach, :create, :delete
default_action :attach

attribute :name, :name_attribute => true, :kind_of => String, :required => true

# Name of the pool that stores the image
attribute :pool, :kind_of => String, :default => 'rbd'

# Size of the image
attribute :size, :kind_of => [Integer, String], :default => '1024'

# Client ID
attribute :id, :kind_of => String, :required => true

# Client keyring
attribute :keyring, :kind_of => String, :required => true

attr_accessor :exists, :attached
