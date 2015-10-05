@test "test rbd is created" {
  rbd info rbd/rbd_test
}

@test "test rbd is in rbdmap" {
  grep rbd_test /etc/ceph/rbdmap
}

@test "test rbd is attached" {
  rbd showmapped|grep 'rbd  rbd_test'
}
