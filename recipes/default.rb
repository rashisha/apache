#
# Cookbook Name:: apache
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
# Apache script to check and start the service
# Install Apache httpd
package 'Install Apache' do 
  package_name node['apache']['package']
  default_release node['apache']['default_release'] unless node['apache']['default_release'].nil?
end

directory "#{node['apache']['dir']}/#{dir}" do
    mode '0755'
    owner 'root'
    group node['apache']['root_group']
  end
  
 # Copy the mod-jk module
 cookbook_file '/usr/lib64/httpd/modules/mod_jk.so' do
  source 'mod_jk.so'
  owner 'apache2'
  group 'apache2'
  mode '0755'
  action :create
end

# Copy worker.properties
template '/etc/httpd/conf/workers.properties' do
  action :create
  source 'workers.properties.erb'
  owner 'root'
  group node['apache']['root_group']
  mode '0644'
  notifies :reload, 'service[apache2]', :immediately
end

# Copy mod-jk file
 template ''/etc/httpd/conf.d/mod-jk.conf' do
  action :create
  source 'mod-jk.conf.erb'
  owner 'root'
  group node['apache']['root_group']
  mode '0644'
  notifies :reload, 'service[apache2]', :immediately
end

 
 template 'httpd.conf' do
  if platform_family?('rhel', 'fedora', 'arch', 'freebsd')
    path "#{node['apache']['conf_dir']}/httpd.conf"
  elsif platform_family?('debian')
    path "#{node['apache']['conf_dir']}/apache2.conf"
  elsif platform_family?('suse')
    path "#{node['apache']['conf_dir']}/httpd.conf"
  end
  action :create
  source 'apache2.conf.erb'
  owner 'root'
  group node['apache']['root_group']
  mode '0644'
  notifies :reload, 'service[apache2]', :immediately
end

# Ensure the httpd service is started

service 'apache2' do
  service_name apache_service_name
  case node['platform_family']
  when 'rhel'
    if node['platform_version'].to_f < 7.0 && node['apache']['version'] != '2.4'
      restart_command "/sbin/service #{apache_service_name} restart && sleep 1"
      reload_command "/sbin/service #{apache_service_name} graceful && sleep 1"
    end
  when 'debian'
    provider Chef::Provider::Service::Debian
  when 'arch'
    service_name apache_service_name
  end
  supports [:start, :restart, :reload, :status]
  action [:enable, :start]
  only_if "#{node['apache']['binary']} -t", :environment => { 'APACHE_LOG_DIR' => node['apache']['log_dir'] }, :timeout => 10
end