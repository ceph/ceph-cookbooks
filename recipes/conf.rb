if node['ceph']['config']['fsid'].nil? || node['ceph']['config']['mon_initial_members'].nil?
  Log.debug("ceph-mds: Trying to retrieve fsid and mon from the ceph-setup role")
  search_query = "roles:ceph-setup AND chef_environment:#{node.chef_environment}"
  search_result = search(:node, search_query)
  if search_result.length < 1
    msg = "ceph-conf: The ceph fsid and mon_initial_members must be set in the config, or the ceph-setup role must be applied to a node."
    Chef::Application.fatal! msg
  end

  fsid = search_result[0]['ceph']['config']['fsid']
  Log.debug("ceph-mds: Found ceph fsid #{fsid} from the ceph-setup role")
  node.set['ceph']['config']['fsid'] = fsid

  mon_initial_members = search_result[0]['ceph']['config']['mon_initial_members']
  Log.debug("ceph-mds: Found ceph mon_initial_members #{mon_initial_members} from the ceph-setup role")
  node.set['ceph']['config']['mon_initial_members'] = mon_initial_members
end

mon_addresses = get_mon_addresses()

is_rgw = false
if node['roles'].include? 'ceph-radosgw'
  is_rgw = true
end

template '/etc/ceph/ceph.conf' do
  source 'ceph.conf.erb'
  variables(
    :mon_addresses => mon_addresses,
    :is_rgw => is_rgw
  )
  mode '0644'
end
