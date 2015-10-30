@test "restapi client key is generated" {
  test -e /etc/ceph/ceph.client.restapi*
}

@test "restapi is configured" {
  test -e /etc/apache2/sites-enabled/restapi.conf
  grep -F 'WSGIScriptAlias / /usr/lib/ceph/restapi.wsgi' /etc/apache2/sites-enabled/restapi.conf > /dev/null
}

@test "restapi is listening on the port" {
  netstat -lnpt | grep 5000
}

@test "restapi is responding with data" {
  wget -q -O - http://127.0.0.1:5000/api/v0.1/mon_status | grep quorum > /dev/null
}
