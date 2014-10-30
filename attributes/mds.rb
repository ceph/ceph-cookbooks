include_attribute 'ceph'

default['ceph']['mds']['init_style'] = node['init_style']
default['ceph']['mds']['fs']['ceph'] = {'data_pool' => 'data', 'metadata_pool' => 'metadata'}

case node['platform_family']
when 'debian'
  packages = ['ceph-mds']
  packages += debug_packages(packages) if node['ceph']['install_debug']
  default['ceph']['mds']['packages'] = packages
else
  default['ceph']['mds']['packages'] = []
end
