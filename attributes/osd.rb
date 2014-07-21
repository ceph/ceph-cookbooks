include_attribute 'ceph'

default['ceph']['osd']['service_name'] = value_for_platform(
  ['ubuntu'] => 'ceph-osd-all-starter',
  'default' => 'ceph'
)

default['ceph']['osd']['secret_file'] = '/etc/chef/secrets/ceph_osd'

case node['platform_family']
when 'debian', 'rhel', 'fedora'
  packages = ['ceph']
  packages += debug_packages(packages) if node['ceph']['install_debug']
  default['ceph']['osd']['packages'] = packages
else
  default['ceph']['osd']['packages'] = []
end
