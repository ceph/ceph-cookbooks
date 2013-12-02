default['ceph']['branch'] = "stable" # Can be stable, testing or dev.
# Major release version to install or gitbuilder branch
default['ceph']['version'] = "dumpling"
default['ceph']['el_add_epel'] = true
default['ceph']['repo_url'] = "http://ceph.com"

case node['platform_family']
when "debian"
  #Debian/Ubuntu default repositories
  default['ceph']['debian']['stable']['repository'] = "#{node['ceph']['repo_url']}/debian-#{node['ceph']['version']}/"
  default['ceph']['debian']['stable']['repository_key'] = "https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc"
  default['ceph']['debian']['testing']['repository'] = "#{node['ceph']['repo_url']}/debian-testing/"
  default['ceph']['debian']['testing']['repository_key'] = "https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc"
  default['ceph']['debian']['dev']['repository'] = "http://gitbuilder.ceph.com/ceph-deb-#{node['lsb']['codename']}-x86_64-basic/ref/#{node['ceph']['version']}"
  default['ceph']['debian']['dev']['repository_key'] = "https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/autobuild.asc"
when "rhel"
  #Redhat/CentOS default repositories
  default['ceph']['rhel']['release'] = "#{node['platform']}#{node['platform_version'].split(".")[0]}"
  default['ceph']['rhel']['stable']['repository'] = "#{node['ceph']['repo_url']}/rpm-#{node['ceph']['version']}/el6/noarch/ceph-release-1-0.el6.noarch.rpm"
  default['ceph']['rhel']['testing']['repository'] = "#{node['ceph']['repo_url']}/rpm-testing/el6/x86_64/ceph-release-1-0.el6.noarch.rpm"
  default['ceph']['rhel']['dev']['name'] = "ceph"
  default['ceph']['rhel']['dev']['description'] = "Ceph"
  default['ceph']['rhel']['dev']['baseurl'] = "http://gitbuilder.ceph.com/ceph-rpm-centos6-x86_64-basic/ref/#{node['ceph']['version']}/x86_64/"
  default['ceph']['rhel']['dev']['enabled'] = "1"
  default['ceph']['rhel']['dev']['priority'] = "1"
  default['ceph']['rhel']['dev']['type'] = "rpm-md"
  default['ceph']['rhel']['dev']['gpgkey'] = "https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/autobuild.asc"
  default['ceph']['rhel']['fastcgi-ceph-basearch']['name'] = "fastcgi-ceph-basearch"
  default['ceph']['rhel']['fastcgi-ceph-basearch']['description'] = "FastCGI basearch packages for Ceph"
  default['ceph']['rhel']['fastcgi-ceph-basearch']['baseurl'] = "http://gitbuilder.ceph.com/mod_fastcgi-rpm-#{node['ceph']['rhel']['release']}-x86_64-basic/ref/master"
  default['ceph']['rhel']['fastcgi-ceph-basearch']['enabled'] = " 1"
  default['ceph']['rhel']['fastcgi-ceph-basearch']['priority'] = "2"
  default['ceph']['rhel']['fastcgi-ceph-basearch']['type'] = "rpm-md"
  default['ceph']['rhel']['fastcgi-ceph-basearch']['gpgkey'] = "https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/autobuild.asc"
  default['ceph']['rhel']['fastcgi-ceph-noarch']['name'] = "fastcgi-ceph-noarch"
  default['ceph']['rhel']['fastcgi-ceph-noarch']['description'] = "FastCGI noarch packages for Ceph"
  default['ceph']['rhel']['fastcgi-ceph-noarch']['baseurl'] = "http://gitbuilder.ceph.com/mod_fastcgi-rpm-#{node['ceph']['rhel']['release']}-x86_64-basic/ref/master"
  default['ceph']['rhel']['fastcgi-ceph-noarch']['enabled'] = "1"
  default['ceph']['rhel']['fastcgi-ceph-noarch']['priority'] = "2"
  default['ceph']['rhel']['fastcgi-ceph-noarch']['type'] = "rpm-md"
  default['ceph']['rhel']['fastcgi-ceph-noarch']['gpgkey'] = "https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/autobuild.asc"
  default['ceph']['rhel']['fastcgi-ceph-source']['name'] = "fastcgi-ceph-source"
  default['ceph']['rhel']['fastcgi-ceph-source']['description'] = "FastCGI source packages for Ceph"
  default['ceph']['rhel']['fastcgi-ceph-source']['baseurl'] = "http://gitbuilder.ceph.com/mod_fastcgi-rpm-#{node['ceph']['rhel']['release']}-x86_64-basic/ref/master"
  default['ceph']['rhel']['fastcgi-ceph-source']['enabled'] = "0"
  default['ceph']['rhel']['fastcgi-ceph-source']['priority'] = "2"
  default['ceph']['rhel']['fastcgi-ceph-source']['type'] = "rpm-md"
  default['ceph']['rhel']['fastcgi-ceph-source']['gpgkey'] = "https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/autobuild.asc"
  default['ceph']['rhel']['apache2-ceph-noarch']['name'] = "apache2-ceph-noarch"
  default['ceph']['rhel']['apache2-ceph-noarch']['description'] = "Apache noarch packages for Ceph"
  default['ceph']['rhel']['apache2-ceph-noarch']['baseurl'] = "http://gitbuilder.ceph.com/apache2-rpm-#{node['ceph']['rhel']['release']}-x86_64-basic/ref/master"
  default['ceph']['rhel']['apache2-ceph-noarch']['enabled'] = "1"
  default['ceph']['rhel']['apache2-ceph-noarch']['priority'] = "2"
  default['ceph']['rhel']['apache2-ceph-noarch']['type'] = "rpm-md"
  default['ceph']['rhel']['apache2-ceph-noarch']['gpgkey'] = "https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/autobuild.asc"
  default['ceph']['rhel']['apache2-ceph-source']['name'] = "apache2-ceph-source"
  default['ceph']['rhel']['apache2-ceph-source']['description'] = "Apache source packages for Ceph"
  default['ceph']['rhel']['apache2-ceph-source']['baseurl'] = "http://gitbuilder.ceph.com/apache2-rpm-#{node['ceph']['rhel']['release']}-x86_64-basic/ref/master"
  default['ceph']['rhel']['apache2-ceph-source']['enabled'] = "0"
  default['ceph']['rhel']['apache2-ceph-source']['priority'] = "2"
  default['ceph']['rhel']['apache2-ceph-source']['type'] = "rpm-md"
  default['ceph']['rhel']['apache2-ceph-source']['gpgkey'] = "https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/autobuild.asc"
when "fedora"
  #Fedora default repositories
  default['ceph']['fedora']['stable']['repository'] = "#{node['ceph']['repo_url']}/rpm-#{node['ceph']['version']}/fc#{node['platform_version']}/x86_64/ceph-release-1-0.fc#{node['platform_version']}.noarch.rpm"
  default['ceph']['fedora']['testing']['repository'] = "#{node['ceph']['repo_url']}/rpm-testing/fc#{node['platform_version']}/x86_64/ceph-release-1-0.fc#{node['platform_version']}.noarch.rpm"
  default['ceph']['fedora']['dev']['name'] = "ceph"
  default['ceph']['fedora']['dev']['description'] = "Ceph"
  default['ceph']['fedora']['dev']['baseurl'] = "http://gitbuilder.ceph.com/ceph-rpm-fc#{node['platform_version']}-x86_64-basic/ref/#{node['ceph']['version']}/RPMS/x86_64/"
  default['ceph']['fedora']['dev']['enabled'] = "1"
  default['ceph']['fedora']['dev']['priority'] = "1"
  default['ceph']['fedora']['dev']['type'] = "rpm-md"
  default['ceph']['fedora']['dev']['gpgkey'] = "https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/autobuild.asc"
  default['ceph']['fedora']['fastcgi-ceph-basearch']['name'] = "fastcgi-ceph-basearch"
  default['ceph']['fedora']['fastcgi-ceph-basearch']['description'] = "FastCGI basearch packages for Ceph"
  default['ceph']['fedora']['fastcgi-ceph-basearch']['baseurl'] = "http://gitbuilder.ceph.com/mod_fastcgi-rpm-fedora#{node['platform_version']}-x86_64-basic/ref/master"
  default['ceph']['fedora']['fastcgi-ceph-basearch']['enabled'] = " 1"
  default['ceph']['fedora']['fastcgi-ceph-basearch']['priority'] = "2"
  default['ceph']['fedora']['fastcgi-ceph-basearch']['type'] = "rpm-md"
  default['ceph']['fedora']['fastcgi-ceph-basearch']['gpgkey'] = "https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/autobuild.asc"
  default['ceph']['fedora']['fastcgi-ceph-noarch']['name'] = "fastcgi-ceph-noarch"
  default['ceph']['fedora']['fastcgi-ceph-noarch']['description'] = "FastCGI noarch packages for Ceph"
  default['ceph']['fedora']['fastcgi-ceph-noarch']['baseurl'] = "http://gitbuilder.ceph.com/mod_fastcgi-rpm-fedora#{node['platform_version']}-x86_64-basic/ref/master"
  default['ceph']['fedora']['fastcgi-ceph-noarch']['enabled'] = "1"
  default['ceph']['fedora']['fastcgi-ceph-noarch']['priority'] = "2"
  default['ceph']['fedora']['fastcgi-ceph-noarch']['type'] = "rpm-md"
  default['ceph']['fedora']['fastcgi-ceph-noarch']['gpgkey'] = "https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/autobuild.asc"
  default['ceph']['fedora']['fastcgi-ceph-source']['name'] = "fastcgi-ceph-source"
  default['ceph']['fedora']['fastcgi-ceph-source']['description'] = "FastCGI source packages for Ceph"
  default['ceph']['fedora']['fastcgi-ceph-source']['baseurl'] = "http://gitbuilder.ceph.com/mod_fastcgi-rpm-fedora#{node['platform_version']}-x86_64-basic/ref/master"
  default['ceph']['fedora']['fastcgi-ceph-source']['enabled'] = "0"
  default['ceph']['fedora']['fastcgi-ceph-source']['priority'] = "2"
  default['ceph']['fedora']['fastcgi-ceph-source']['type'] = "rpm-md"
  default['ceph']['fedora']['fastcgi-ceph-source']['gpgkey'] = "https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/autobuild.asc"
  default['ceph']['fedora']['apache2-ceph-noarch']['name'] = "apache2-ceph-noarch"
  default['ceph']['fedora']['apache2-ceph-noarch']['description'] = "Apache noarch packages for Ceph"
  default['ceph']['fedora']['apache2-ceph-noarch']['baseurl'] = "http://gitbuilder.ceph.com/apache2-rpm-fedora#{node['platform_version']}-x86_64-basic/ref/master"
  default['ceph']['fedora']['apache2-ceph-noarch']['enabled'] = "1"
  default['ceph']['fedora']['apache2-ceph-noarch']['priority'] = "2"
  default['ceph']['fedora']['apache2-ceph-noarch']['type'] = "rpm-md"
  default['ceph']['fedora']['apache2-ceph-noarch']['gpgkey'] = "https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/autobuild.asc"
  default['ceph']['fedora']['apache2-ceph-source']['name'] = "apache2-ceph-source"
  default['ceph']['fedora']['apache2-ceph-source']['description'] = "Apache source packages for Ceph"
  default['ceph']['fedora']['apache2-ceph-source']['baseurl'] = "http://gitbuilder.ceph.com/apache2-rpm-fedora#{node['platform_version']}-x86_64-basic/ref/master"
  default['ceph']['fedora']['apache2-ceph-source']['enabled'] = "0"
  default['ceph']['fedora']['apache2-ceph-source']['priority'] = "2"
  default['ceph']['fedora']['apache2-ceph-source']['type'] = "rpm-md"
  default['ceph']['fedora']['apache2-ceph-source']['gpgkey'] = "https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/autobuild.asc"
when "suse"
  #(Open)SuSE default repositories
  # Chef doesn't make a difference between suse and opensuse
  suse = %x[ head -n1 /etc/SuSE-release| awk '{print $1}' ].chomp.downcase #can be suse or opensuse
  if suse == "suse"
    suse = "sles"
  end
  suse_version = suse << %x[ grep VERSION /etc/SuSE-release | awk -F'= ' '{print $2}' ].chomp
  default['ceph']['suse']['stable']['repository'] = "#{node['ceph']['repo_url']}/rpm-#{node['ceph']['version']}/#{suse_version}/x86_64/ceph-release-1-0.#{suse_version}.noarch.rpm"
  default['ceph']['suse']['testing']['repository'] = "#{node['ceph']['repo_url']}/rpm-testing/#{suse_version}/x86_64/ceph-release-1-0.#{suse_version}.noarch.rpm"
else
  raise "#{node['platform_family']} is not supported"
end
