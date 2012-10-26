#
# Author:: Julian C. Dunn <jdunn@secondmarket.com>
#
# Cookbook Name:: chef-server
# Recipe:: mtce-and-backup-jobs
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

include_recipe "aws"
include_recipe "python"

# Nightly backups on /backups at 3:05 a.m.

if Chef::Config['solo']
    Chef::Log.warn("The backup job requires search to get the AWS credentials. Chef Solo does not support search.")
else

    creds = Chef::EncryptedDataBagItem.load("secrets", "aws")

    aws_ebs_volume "backups_ebs_volume_from_snapshot" do
      aws_access_key creds['aws_access_key_id']
      aws_secret_access_key creds['aws_secret_access_key']
      device "/dev/sdf"
      snapshot_id "snap-8cfe68fd"
      action [ :create, :attach ]
    end

    directory "/backups" do
      owner "root"
      group "root"
      action :create
    end

    mount "/backups" do
      device "/dev/sdf1"
      fstype "xfs"
      options "rw,noexec,noatime,nodiratime"
      action [:mount, :enable]
    end

    cron "backup_chef_configs" do
      hour "3"
      minute "5"
      command "/bin/tar -czf /backups/chef_server_backup.`date +\\%F`.tar.gz /var/lib/chef /etc/chef"
      user "root"
      action :create
    end

    python_pip "CouchDB" do
      action :install
    end

    cron "backup_couchdb" do
      hour "3"
      minute "5"
      command "/usr/bin/couchdb-dump http://127.0.0.1:5984/chef | /bin/gzip -9c > /backups/chef.`date +\\%F`.couchdb.gz"
      user "root"
      action :create
    end

    cron "cleanup_old_chef_backups" do
      hour "4"
      minute "5"
      command "/usr/bin/find /backups -type f -mtime +30 -exec rm {} \;"
      user "root"
      action :create
    end
end
