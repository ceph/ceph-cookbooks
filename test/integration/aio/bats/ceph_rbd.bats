@test "test rbd is created" {
  rbd info rbd/rbd_test --id=rbd.vagrant --keyring=/etc/ceph/ceph.client.rbd.vagrant.secret
}

@test "test rbd is in rbdmap" {
  grep rbd_test /etc/ceph/rbdmap
}

@test "test rbd is attached" {
  rbd showmapped --id=rbd.vagrant --keyring=/etc/ceph/ceph.client.rbd.vagrant.secret |grep 'rbd  rbd_test'
}
