vpc_cidr = "192.168.0.0/24"
subnet_cidr = "192.168.0.0/25"
sg_cidr = "185.63.117.0/29"
sg_port_1 = 22
sg_port_2 = 443
instance_ami = "ami-031b0f67"
instance_type = "t2.small"
instance_keypair = "research"

tag_AssetProtectionLevel = "99"
tag_Brand = "FCTS"
tag_CostCenter = "90326"
tag_Team = "FCTS Operations"
tag_Creator = "NA"

ssh_user = "centos"
chef-server-script = "scripts/chef-server.sh"
chef-server-script-dest = "/tmp/chef-server.sh"