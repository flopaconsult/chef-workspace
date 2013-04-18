define(:workspace,
  :workspace_user         => "chef-workspace",                          #
  :aws_databag_item       => "aws",
  :chef_databag_item      => "chef",
  :git_databag_item       => "git",
  :repo_url               => nil
) do
  include_recipe "chef-workspace::install_knife"
  
  chef_databag = node['chef_workspace']['chef_databag']
  chef_databag_item = params[:chef_databag_item]
  begin
    config = data_bag_item(chef_databag, chef_databag_item)
  rescue
    Chef::Log.fatal("Could not find the '#{chef_databag_item}' item in the '#{chef_databag}' data bag")
    raise
  end

  aws_databag = node['chef_workspace']['aws_databag']
  aws_databag_item = params[:aws_databag_item]
  begin
    aws = data_bag_item(aws_databag, aws_databag_item)
  rescue
    Chef::Log.fatal("Could not find the '#{aws_databag_item}' item in the '#{aws_databag}' data bag")
    raise
  end

  workspace_user = params[:workspace_user]
  chef_config workspace_user do
    aws_access_key_id      aws['aws_access_key_id']         #for knife.rb to provision new servers
    aws_secret_access_key  aws['aws_secret_access_key']
    chef_server_url        config['chef_server_url']
    user_name              workspace_user                          #user accout (home will be located in /var/#{user_name})
    node_name              config['node_name']
    client_key             config['client_key']             #usually: webui.pem
    client_pem             config['client_pem']             #~/.chef/webui.pem content
    validation_client_name config['validation_client_name'] #usually: chef-validator
    validation_key         config['validation_key']         #usually: validation.pem
    validation_pem         config['validation_pem']         #~/.chef/validation.pem content
    chef_server_url        config['chef_server_url']
    cookbook_path          config['cookbook_path']
    node_name              config['node_name']
  end

  git_databag_item = params[:git_databag_item]
  git_config workspace_user do
    user        workspace_user
    user_dir    "#{node['chef_workspace']['user_dir']}/#{workspace_user}"
    git_key     "id_rsa_github"
    databag_key  git_databag_item
  end

  git "#{node['chef_workspace']['user_dir']}/#{workspace_user}/chef-repo" do
    repo params[:repo_url]
    reference "master"
    user workspace_user
    group workspace_user
    action :sync
    ssh_wrapper "#{node['chef_workspace']['user_dir']}/#{workspace_user}/wrap-ssh4git.sh"
  end

  ssh_config do
    user          workspace_user
    user_home     "#{node['chef_workspace']['user_dir']}/#{workspace_user}"
    data_bag_item 'id_rsa_amazon'
  end
end
