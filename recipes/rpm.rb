include_recipe "yum"

platform_family = node['platform_family']

case platform_family
when "rhel"
  if node['ceph']['el_add_epel'] == true
    include_recipe "yum::epel"
  end
end

branch = node['ceph']['branch']
if branch == "dev" and platform_family != "centos" and platform_family != "fedora"
  raise "Dev branch for #{platform_family} is not yet supported"
end

repo_list = []
if branch == "dev"
  # Add the Dev repo to the list of repo's to be setup later
  repo_list.push("dev")
else
  # This is a stable or testing branch
  system "rpm -U #{node['ceph'][platform_family][branch]['repository']}"
end

# Setup the Ceph FastCGI/Apache repo's similar to Ubuntu
if node['roles'].include?("ceph-radosgw") \
  && node["ceph"]["radosgw"]["webserver_companion"] == "apache2" \
  && node["ceph"]["radosgw"]["use_apache_fork"] == true
    if platform_family == "rhel"
      release = node['ceph']['rhel']['release']
    else
      release = "fedora#{node['platform_version']}"
    end
    if !(release == "ferdora18" || release == "fedora19" || release == "rhel6" || release == "centos6")
      Log.info("Ceph's Apache and Apache FastCGI forks not available for #{platform_family} version #{version}")
    else
      repo_list.push("fastcgi-ceph-basearch")
      repo_list.push("fastcgi-ceph-noarch")
      repo_list.push("fastcgi-ceph-source")
      repo_list.push("apache2-ceph-noarch")
      repo_list.push("apache2-ceph-source")
    end
end

for repo in repo_list
  repository = node["ceph"][platform_family][repo]
  yum_repository repository["name"] do
    repo_name repository["name"]
    description repository["description"]
    url repository["baseurl"]
    enabled repository["enabled"]
    priority repository["priority"]
    type repository["type"]
    key repository["name"]
    action :add
  end
  yum_key repository["name"] do
    url repository["gpgkey"]
    action :add
  end
end
