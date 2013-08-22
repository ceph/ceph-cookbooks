#
# Override the following default to have pools setup automatically by the
# ceph::pools recipe.
#

default["ceph"]["pools"] = []

#
# Below is a sample of how the override can be done.
# Uncomment it to try it out.
#

#default["ceph"]["pools"] = [
#  {
#    "name"    => "test1"
#  },
#  { "name"    => "test2",
#    "pg-num"  => 10
#  },
#  {
#    "name"    => "test3",
#    "pg-num"  => 20,
#    "pgp-num" => 15
#  }
#]
