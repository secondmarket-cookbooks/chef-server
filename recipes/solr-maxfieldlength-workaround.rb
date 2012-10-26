#
# Author:: Julian C. Dunn <jdunn@secondmarket.com>
#
# Cookbook Name:: chef-server
# Recipe:: solr-maxfieldlength-workaround
#
# Copyright (C) 2012 SecondMarket Labs, LLC.
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

# Work around bug in CHEF-2346.
# http://tickets.opscode.com/browse/CHEF-2346

cookbook_file "#{node["chef_server"]["path"]}/solr/home/conf/solrconfig.xml" do
    source "solrconfig.xml"
    owner "root"
    group "root"
    mode 00644
    action :create
    notifies :restart, "service[chef-solr]"
end
