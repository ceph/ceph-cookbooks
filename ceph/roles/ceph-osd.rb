name "ceph-osd"
description "Ceph Object Storage Device"
run_list(
        'recipe[ceph::bootstrap_osd]'
)
