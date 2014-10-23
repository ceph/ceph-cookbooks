actions :add
default_action :add

attribute :name, :kind_of => String, :name_attribute => true

# pool settings
attribute :region, :kind_of => String
attribute :region_root_pool, :kind_of => String, :default => nil  # defaults to .#{region}.rgw.root
attribute :zone, :kind_of => String
attribute :zone_root_pool, :kind_of => String, :default => nil  # defaults to .#{zone}.rgw.root

# other radosgw settings
attribute :keyname, :kind_of => String, :default => nil  # defaults to client.radosgw.#{zone}.#{hostname}, used to generate key
attribute :dns_name, :kind_of => String
attribute :dns_aliases, :kind_of => Array, :default => nil  # turns into ServerAlias lines
attribute :socket_path, :kind_of => String, :default => nil # defaults to /var/run/ceph-radosgw/ceph-radosgw.#{zone}.#{hostname}
attribute :print_continue, :kind_of => [TrueClass, FalseClass], :default => nil

def initialize(*args)
  super
  @action = :add
end
