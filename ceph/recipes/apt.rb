execute "add autobuild gpg key to apt" do
  command <<-EOH
wget -q -O- https://raw.github.com/ceph/ceph/master/keys/release.asc \
| sudo apt-key add -
  EOH
end

template '/etc/apt/sources.list.d/ceph.list' do
  owner 'root'
  group 'root'
  mode '0644'
  source 'apt-sources-list.release.erb'
  if node[:lsb][:codename] == "precise"
    distribution = "oneiric"
  else
    distribution = node[:lsb][:codename]
  end
  variables(
    :codename => distribution
    )
end

execute 'apt-get update'
