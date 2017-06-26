aws_profile_name = "default"

aws_region = "eu-west-1"

public_key = "${file("key.pub")}"

private_key = "${file("key")}"

certificate_email = "tech@example.com"

route53_zone_name = "example.com."

subdomain_name = "vpn.example.com"

# vpc_cidr_block = "10.0.0.0/16"
# subnet_cidr_block = "10.0.0.0/16"
# ssh_port = 22
# ssh_cidr = "0.0.0.0/0"
# https_port = 443
# https_cidr = "0.0.0.0/0"
# tcp_port = 943
# tcp_cidr = "0.0.0.0/0"
# udp_port = 1194
# udp_cidr = "0.0.0.0/0"
# subdomain_ttl = 60
# ami = "ami-f53d7386"
# instance_type = "t2.medium"
# admin_user = "openvpn"
# admin_password = "openvpn"

