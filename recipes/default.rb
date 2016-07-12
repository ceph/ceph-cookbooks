include_recipe 'ceph::repo' if node['ceph']['install_repo']

# Tools needed by cookbook (including ceph-common, which creates the ceph user).
node['ceph']['packages'].each do |pck|
  package pck
end

include_recipe 'ceph::conf'

chef_gem 'netaddr'
