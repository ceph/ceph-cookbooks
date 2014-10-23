@test "radosgw for test zone is configured" {
  # check that the settings look right
  settings=`cat /etc/ceph/ceph.conf | awk '/^\[/ { $1 ~ /\[client.radosgw.us-test\]/ ? mode=1 : mode=0 } /^ +/ {if (mode==1) print $0;}'`
  test -n "$settings"
  echo "$settings" | grep 'rgw region = default' > /dev/null
  echo "$settings" | grep 'rgw region root pool = .rgw.root' > /dev/null
  echo "$settings" | grep 'rgw zone = default' > /dev/null
  echo "$settings" | grep 'rgw zone root pool = .rgw.root' > /dev/null
  echo "$settings" | grep 'keyring = /etc/ceph/ceph.client.radosgw.us-test.keyring' > /dev/null
  echo "$settings" | grep 'rgw socket path = /var/run/ceph-radosgw/radosgw.us-test' > /dev/null
  echo "$settings" | grep 'rgw dns name = ceph.test' > /dev/null
  echo "$settings" | grep -v 'api_aliases' > /dev/null
  echo "$settings" | grep -v 'rgw dns aliases' > /dev/null
  echo "$settings" | grep 'rgw print continue = true' > /dev/null
}

@test "radosgw for test zone has keys" {
  test -e /etc/ceph/ceph.client.radosgw.us-test.keyring
}
@test "radosgw for test zone should start" {
  test -e /var/lib/ceph/radosgw/ceph-radosgw.us-test
}
@test "radosgw for test zone is running" {
  ps -ef | grep 'radosg[w].*radosgw.us-test' > /dev/null
  test -e /var/run/ceph-radosgw/radosgw.us-test
}

@test "radosgw for test zone has apache config" {
  filename=/etc/apache2/sites-enabled/rgw-default.conf
  test -e $filename
  grep 'FastCgiExternalServer /var/www/s3gw-default.fcgi -socket /var/run/ceph-radosgw/radosgw.us-test' $filename > /dev/null
  grep 'ServerName ceph.test' $filename > /dev/null
  grep 'ServerAlias \*.ceph.test' $filename > /dev/null
  grep 'RewriteRule.*s3gw-default.fcgi' $filename > /dev/null
}

@test "radosgw for test zone responds via apache" {
  wget http://localhost --header=host:ceph.test -O- | grep ListAllMyBucketsResult > /dev/null
}
@test "radosgw for test zone subdomain responds via apache" {
  curl http://localhost --header host:sub.ceph.test | grep NoSuchBucket > /dev/null
}
