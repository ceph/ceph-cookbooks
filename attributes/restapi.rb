#
# Cookbook Name:: ceph
# Attributes:: restapi
#
# Copyright 2011, DreamHost Web Hosting
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default['ceph']['restapi']['admin_email'] = 'admin@example.com'
default['ceph']['restapi']['addr'] = '127.0.0.1:5000'	# vhost port
default['ceph']['restapi']['name'] = nil		# don't add a servername line
default['ceph']['restapi']['port'] = 5000		# add this port to the listening ports
default['ceph']['restapi']['user'] = 'www-data'		# owner of keyring and logfile
default['ceph']['restapi']['group'] = 'www-data'	# owner of keyring and logfile
default['ceph']['restapi']['webserver_companion'] = 'apache2' # can be false
