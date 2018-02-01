require 'io/console'
load 'config/config.rb'

ENV['CONFIG_FOLDER']  = 'config'
ENV['TERRAFORM_LINK'] = $config['terraform_link']
ENV['TMP_DIR']        = $config['tmp_dir']
ENV['TERRAFORM_FILE'] = $config['terraform_file']
ENV['CHEF_REPO']    = $config['chef_repo']

ENV['TF_SECRET_FILE']    = "#{ENV['CONFIG_FOLDER']}/secret.tfvars"
ENV['TF_CONFIG_FILE']    = "#{ENV['CONFIG_FOLDER']}/config.tfvars"

ADMIN_KEY             = $config['admin_key']
VALIDATOR_KEY         = $config['validator_key']

def install_packages
  system("yum install -y unzip wget")
end

namespace :terraform do
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
    system("unzip $TMP_DIR/$TERRAFORM_FILE -d $TMP_DIR && rm -r $TMP_DIR/$TERRAFORM_FILE")
    system("chmod 755 $TMP_DIR/terraform && mv $TMP_DIR/terraform /usr/bin")
  end

  desc "Apply terraform"
  task :apply do
    system('terraform apply -var-file="$TF_SECRET_FILE" -var-file="$TF_CONFIG_FILE"')
  end

  desc "Plan terraform"
  task :plan do
    system('terraform plan -var-file="$TF_SECRET_FILE" -var-file="$TF_CONFIG_FILE"')
  end
end

namespace :chef do
 task :prepare do
   chef_server_ip  = `terraform output chef-server-ip`.chomp
   chef_server_dns = `terraform output chef-server-private-dns`.chomp
   system("ssh -i ./research.pem centos@#{chef_server_ip} \"sudo cp /root/#{ADMIN_KEY} /tmp\"")
   system("ssh -i ./research.pem centos@#{chef_server_ip} \"sudo cp /root/#{VALIDATOR_KEY} /tmp\"")
   system("scp -i ./research.pem centos@#{chef_server_ip}:/tmp/#{ADMIN_KEY} ./$CHEF_REPO/.chef")
   system("scp -i ./research.pem centos@#{chef_server_ip}:/tmp/#{VALIDATOR_KEY} ./$CHEF_REPO/.chef")
   system("echo \"#{chef_server_ip} #{chef_server_dns}\" >> /etc/hosts")
   system("sed -i \"s/\\(chef_server_url *'https:\\/\\/\\)\\(.*\\)\\(\\/organizations\\/myorg'\\)/\\1#{chef_server_dns}\\3/g\" $CHEF_REPO/.chef/knife.rb")
 end
end