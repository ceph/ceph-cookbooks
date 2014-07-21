include_attribute 'ceph'

default['ceph']['mds']['init_style'] = node['ceph']['init_style']
default['ceph']['mds']['service_name'] = value_for_platform(
  ['ubuntu'] => 'ceph-mds-all-starter',
  'default' => 'ceph'
)

case node['platform_family']
when 'debian'
  packages = ['ceph-mds']
  packages += debug_packages(packages) if node['ceph']['install_debug']
  default['ceph']['mds']['packages'] = packages
else
  default['ceph']['mds']['packages'] = []
end
