name "ceph-setup"
description "Role for the setup of a Ceph cluster. Includes a mon role."
run_list(
        'recipe[ceph::setup]',
        'role[ceph-mon]'
)
