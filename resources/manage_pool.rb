#
# Author:: Jesse Pretorius <jesse.pretorius@bcx.co.za>
# Cookbook Name:: ceph
# Resources:: manage_pool
#
# Copyright 2013, Business Connexion (Pty) Ltd
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

actions :create

attribute :name,     :kind_of => String,  :name_attribute => true
attribute :pg_num,   :kind_of => Integer, :default => 8
attribute :pgp_num,  :kind_of => Integer
attribute :min_size, :kind_of => Integer
