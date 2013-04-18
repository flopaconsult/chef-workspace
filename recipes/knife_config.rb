user_name = node[:chef_workspace][:name]
home_dir = "#{node['chef_workspace']['user_dir']}/#{user_name}"

user user_name do
  shell "/bin/bash"
  comment "Chef workspace user"
  supports :manage_home => true
  home home_dir
end

directory "#{home_dir}/.chef" do
  owner user_name
  group user_name
  mode "0700"
  action :create
end

template "#{home_dir}/.chef/knife.rb" do
  owner user_name
  group user_name
  mode "0600"
  source "knife.rb.erb"
  variables(
    :repo => node[:chef_workspace][:repo],
    :chef_server => node[:chef_workspace][:chef_server],
    :aws_access_key_id => node[:chef_workspace][:aws_access_key_id],
    :aws_secret_access_key => node[:chef_workspace][:aws_access_key_id],
    :cookbook_path => "\#\{current_dir\}/../cookbooks\",\"\#\{current_dir\}/../site-cookbooks"
  )
end

cookbook_file "#{home_dir}/.chef/workspace.pem" do
  source "workspace-#{node[:chef_workspace][:client_key]}.pem"
  owner user_name
  group user_name
  mode "0600"
end
