default['ceph']['install_debug'] = true
default['ceph']['encrypted_data_bags'] = false
default['ceph']['config']['global']['auth cluster required'] = "cephx"
default['ceph']['config']['global']['auth service required'] = "cephx"
default['ceph']['config']['global']['auth client required'] = "cephx"
