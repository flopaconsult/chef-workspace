if (platform?("ubuntu") && node.platform_version.to_f >= 10.04)
  # otherwise page libxslt-dev is not found (Ubuntu 10.04 and 12.04)
  e = execute "aptitude update" do
    ignore_failure true
    command "apt-get update"
    action :nothing
  end
  e.run_action(:run) 



    

  #### start of additional libs for ubuntu 12.04 ####
  if (platform?("ubuntu") && node.platform_version.to_f >= 12.04)
  e = package "build-essential"  do
    action :nothing
  end
  e.run_action(:install) 

    #install nokogiri_prereq
  e = package "zlib1g-dev"  do
    action :nothing
  end
  e.run_action(:install) 

    #install nokogiri_prereq
  e = package "libssl-dev"  do
    action :nothing
  end
  e.run_action(:install) 

    #install nokogiri_prereq
  e = package "libreadline6-dev"  do
    action :nothing
  end
  e.run_action(:install) 

    #install nokogiri_prereq
  e = package "libyaml-dev"  do
    action :nothing
  end
  e.run_action(:install) 

end

  #### end of additional libs for ubuntu 12.04 ####

  #install nokogiri_prereq
  e = package "libxslt-dev"  do
    action :nothing
  end
  e.run_action(:install) 

  #install nokogiri_prereq
  e = package "libxml2-dev"  do
    action :nothing
  end
  e.run_action(:install)

end

Gem.clear_paths

gem_package "knife-ec2" 
