#
# Author:: Kyle Bader <kyle.bader@dreamhost.com>
# Cookbook Name:: ceph_test
# Recipe:: radosgw_restart
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

# restarts radosgw
# during a normal run, Ceph would have the custom radosgw pools already running
# during a test run, the pool metadata hasn't been fully installed by the time
# the alt radosgw starts up, so it fails to start.
# we can't restart in bats, because bats patiently waits for the
# spawned children processes, including radosgw, to finish
bash 'restart radosgw services' do
  code <<-EOF
  if [ -e /etc/init/shutdown.conf ]; then
    service radosgw-all stop
    service radosgw-all-starter start
  else
    service radosgw stop
    service radosgw start
  fi
  EOF
end
