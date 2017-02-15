include_recipe 'ceph::repo' if node['ceph']['install_repo']

# Tools needed by cookbook
node['ceph']['packages'].each do |pck|
  package pck
end

include_recipe 'ceph::conf'

chef_gem 'netaddr'
