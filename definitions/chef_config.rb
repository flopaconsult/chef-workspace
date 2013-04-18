define(:chef_config,
  :action                 => [:create],                             # 
  :node_name              => "chef-webui",                          #
  :client_key             => "webui.pem",                           #
  :client_pem             => nil,                                   #
  :validation_client_name => "chef-validator",                      #
  :validation_key         => "validation.pem",                      #
  :validation_pem         => nil,                                   #
  :chef_server_url       => "http://localhost:4000/",               # 
  :cookbook_path         => "\#\{current_dir\}/../cookbooks",       # 
  :user_name             => "chef-workspace",                       # 
  :aws_access_key_id     => nil,                                    # 
  :aws_secret_access_key => nil                                     # 
  ) do

  home_dir = "#{node[:chef_workspace][:user_dir]}/#{params[:user_name]}"

  user params[:user_name] do
    shell "/bin/bash"
    comment "Chef workspace user"
    supports :manage_home => true
    home home_dir
  end

  directory "#{home_dir}/.chef" do
    owner params[:user_name]
    group params[:user_name]
    mode "0700"
    action :create
  end

  template "#{home_dir}/.chef/knife.rb" do
    owner params[:user_name]
    group params[:user_name]
    mode "0600"
    source "knife.rb.erb"
    cookbook "chef-workspace"
    variables(
      :node_name              => params[:node_name],
      :client_key             => params[:client_key],
      :validation_client_name => params[:validation_client_name],
      :validation_key         => params[:validation_key],
      :validation_pem         => params[:validation_pem],
      :chef_server_url        => params[:chef_server_url],
      :cookbook_path          => params[:cookbook_path],
      :aws_access_key_id      => params[:aws_access_key_id],
      :aws_secret_access_key  => params[:aws_secret_access_key]
    )
  end

  file "#{home_dir}/.chef/#{params[:client_key]}" do
    content params[:client_pem]
    owner params[:user_name]
    group params[:user_name]
    mode "0600"
  end

  file "#{home_dir}/.chef/#{params[:validation_key]}" do
    content params[:validation_pem]
    owner params[:user_name]
    group params[:user_name]
    mode "0600"
  end

end
