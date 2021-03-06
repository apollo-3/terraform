load 'config/config.rb'

ENV['CONFIG_FOLDER']  = 'config'
ENV['TERRAFORM_LINK'] = $config['terraform_link']
ENV['TMP_DIR']        = $config['tmp_dir']
ENV['TERRAFORM_FILE'] = $config['terraform_file']
ENV['CHEF_REPO']      = $config['chef_repo']
ENV['SSH_USER']       = $config['ssh_user']
ENV['SSH_KEY']        = $config['ssh_key']
ENV['SSH_OPTS']       = $config['ssh_opts']
ENV['EDITOR']         = $config['editor']

ENV['TF_SECRET_FILE'] = "#{ENV['CONFIG_FOLDER']}/secret.tfvars"
ENV['TF_CONFIG_FILE'] = "#{ENV['CONFIG_FOLDER']}/config.tfvars"

ADMIN_KEY             = $config['admin_key']
VALIDATOR_KEY         = $config['validator_key']

# Install System Dependencies
def install_packages
  system("yum install -y unzip wget")
end

# Get output parameters from terraform
def get_terraform_output
  {
    'chef_server_ip'  => `terraform output chef-server-ip`.chomp,
    'chef_server_dns' => `terraform output chef-server-private-dns`.chomp,
    'test_db_ip'      => `terraform output test-db-ip`.chomp,
    'test_db_dns'     => `terraform output test-db-private-dns`.chomp,
    'test_app_ip'     => `terraform output test-app-ip`.chomp,
    'test_app_dns'    => `terraform output test-app-private-dns`.chomp
  }
end

namespace :terraform do
  tf_options = "-var-file=\"$TF_SECRET_FILE\" -var-file=\"$TF_CONFIG_FILE\""

  run_tasks = ["install", "apply"]
  desc "Run terraform"
  task :run do
    run_tasks.each do |task_name|
      Rake::Task["terraform:#{task_name}"].invoke
    end
  end

  desc "Install terraform"
  task :install do
    system("wget $TERRAFORM_LINK -O $TMP_DIR/$TERRAFORM_FILE")
    system("unzip $TMP_DIR/$TERRAFORM_FILE -d $TMP_DIR && " \
           "rm -r $TMP_DIR/$TERRAFORM_FILE")
    system("chmod 755 $TMP_DIR/terraform && " \
           "mv $TMP_DIR/terraform /usr/bin")
  end

  desc "Apply terraform"
  task :apply do
    system("terraform apply #{tf_options}")
  end

  desc "Plan terraform"
  task :plan do
    system("terraform plan #{tf_options}")
  end

  desc "Destroy terraform"
  task :destroy do
    system("terraform destroy #{tf_options}")
  end
end

namespace :chef do
  desc "Prepare chef"
  task :prepare do
    output          = get_terraform_output
    chef_server_ip  = output['chef_server_ip']
    chef_server_dns = output['chef_server_dns']
    test_db_ip      = output['test_db_ip']
    test_db_dns     = output['test_db_dns']
    test_app_ip     = output['test_app_ip']
    test_app_dns    = output['test_app_dns']

    # Download all keys from chef-server & configure knife
    system("ssh $SSH_OPTS -i $SSH_KEY $SSH_USER@#{chef_server_ip} " \
           "\"sudo cp /root/#{ADMIN_KEY} /tmp\"")
    system("ssh $SSH_OPTS -i $SSH_KEY $SSH_USER@#{chef_server_ip} " \
           "\"sudo cp /root/#{VALIDATOR_KEY} /tmp\"")
    system("scp $SSH_OPTS -i $SSH_KEY $SSH_USER@#{chef_server_ip}" \
           ":/tmp/#{ADMIN_KEY} ./$CHEF_REPO/.chef")
    system("scp $SSH_OPTS -i $SSH_KEY $SSH_USER@#{chef_server_ip}" \
           ":/tmp/#{VALIDATOR_KEY} ./$CHEF_REPO/.chef")
    system("echo \"#{chef_server_ip} #{chef_server_dns}\" >> /etc/hosts")
    system("sed -i \"s/\\(chef_server_url *'https:\\/\\/\\)\\(.*\\)\\(\\/" \
           "organizations\\/myorg'\\)/\\1#{chef_server_dns}\\3/g\" " \
           "$CHEF_REPO/.chef/knife.rb")
    system("cd $CHEF_REPO && knife ssl fetch")

    # Bootstrap clients & upload roles
    clients = [{'ip' => test_db_ip, 'dns' => test_db_dns, 'role' => 'db'},
               {'ip' => test_app_ip, 'dns' => test_app_dns, 'role' => 'app'}]
    clients.each do |client|
      system("cd $CHEF_REPO && knife bootstrap #{client['ip']} " \
             "-x $SSH_USER -i ../$SSH_KEY --sudo -N #{client['dns']}")
      system("cd $CHEF_REPO && knife node environment set #{client['dns']} dev")
      system("cd $CHEF_REPO && knife role from file roles/#{client['role']}.json")
    end

    # Upload environment files
    system("cd $CHEF_REPO && knife environment from file environments/dev.json")

    # Create Data Bags
    data_bags = [{'bag' => 'db',   'id' => 'mysql'},
                 {'bag' => 'keys', 'id' => 'aws'}]
    data_bags.each do |data_bag|
      system("cd $CHEF_REPO && export EDITOR=$EDITOR && " \
             "knife data bag create #{data_bag['bag']} #{data_bag['id']}")
      system("cd $CHEF_REPO && export EDITOR=$EDITOR && " \
             "knife data bag from file #{data_bag['bag']} #{data_bag['id']}.json")
    end

    # Upload cookbooks
    system("cd $CHEF_REPO && knife cookbook upload -a")
  end

  desc "Chef provision"
  task :provision do
    output       = get_terraform_output
    test_db_ip   = output['test_db_ip']
    test_db_dns  = output['test_db_dns']
    test_app_ip  = output['test_app_ip']
    test_app_dns = output['test_app_dns']

    # Run dependency recipes on clients & set node roles
    clients = [{'ip'     => test_db_ip,
                'recipe' => 'dependencies::db',
                'role'   => 'db',
                'dns'    => test_db_dns},
               {'ip'     => test_app_ip,
                'recipe' => 'dependencies::app',
                'role'   => 'app',
                'dns'    => test_app_dns}
              ]
    clients.each do |client|
      system("ssh $SSH_OPTS -i $SSH_KEY $SSH_USER@#{client['ip']} " \
             "\"sudo chef-client --runlist 'recipe[#{client['recipe']}]'\"")
      system("cd $CHEF_REPO && knife node run_list set #{client['dns']} " \
             "'role[#{client['role']}]'")
      system("ssh $SSH_OPTS -i $SSH_KEY $SSH_USER@#{client['ip']} " \
             "\"sudo chef-client\"")
    end
  end
end