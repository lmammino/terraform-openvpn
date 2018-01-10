aws_profile_name = "default"

aws_region = "eu-west-1"

ami = "ami-f53d7386" # NOTE: amis are region specific, and listed at https://aws.amazon.com/marketplace/fulfillment?productId=fe8020db-5343-4c43-9e65-5ed4a825c931&ref_=dtl_psb_continue - click the 'launch manual' button

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
# instance_type = "t2.medium"
# admin_user = "openvpn"
# admin_password = "openvpn"
