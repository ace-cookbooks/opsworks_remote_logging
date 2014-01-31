service 'rsyslog' do
  supports :restart => true, :status => true
  action :nothing
end

if node[:remote_logging][:cert_url]
  package 'rsyslog-gnutls' do
    action :install
    notifies :restart, 'service[rsyslog]'
  end

  remote_file "/etc/syslog.remote.crt" do
    source node[:remote_logging][:cert_url]
    checksum node[:remote_logging][:cert_sha256_checksum]
  end
end

template "/etc/rsyslog.d/remote.conf" do
  cookbook "opsworks_remote_logging"
  source "remote.conf.erb"
  owner 'root'
  group 'root'
  mode 0644
  notifies :restart, 'service[rsyslog]'
  variables({
    :host => node[:remote_logging][:host],
    :port => node[:remote_logging][:port],
    :use_tls => (node[:remote_logging][:cert_url] != nil && node[:remote_logging][:cert_url] != ""),
    :filters => node[:remote_logging][:filters]
  })
end
