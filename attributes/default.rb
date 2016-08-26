default['apache']['root_group'] = 'root'
default['apache']['service_name'] = 'httpd'
default['apache']['dir']         = '/etc/httpd'
default['apache']['conf_dir']    = '/etc/httpd/conf'
case node['platform']
when 'redhat', 'centos', 'scientific', 'fedora', 'amazon', 'oracle'
  default['apache']['package'] = 'httpd'
  default['apache']['devel_package'] = 'httpd-devel'
    else
      default['apache']['package'] = 'httpd22'
      default['apache']['devel_package'] = 'httpd22-devel'
    end