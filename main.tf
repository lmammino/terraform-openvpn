variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  default = "10.0.0.0/16"
}

resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr_block}"
}

resource "aws_subnet" "vpn_subnet" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.subnet_cidr_block}"
}

variable "public_key" {}

resource "aws_key_pair" "openvpn" {
  key_name   = "openvpn-key"
  public_key = "${var.public_key}"
}

variable "ssh_port" {
  default = 22
}

variable "ssh_cidr" {
  default = "0.0.0.0/0"
}

variable "https_port" {
  default = 443
}

variable "https_cidr" {
  default = "0.0.0.0/0"
}

variable "tcp_port" {
  default = 943
}

variable "tcp_cidr" {
  default = "0.0.0.0/0"
}

variable "udp_port" {
  default = 1194
}

variable "udp_cidr" {
  default = "0.0.0.0/0"
}

resource "aws_security_group" "openvpn" {
  name        = "openvpn_sg"
  description = "Allow traffic needed by openvpn"
  vpc_id      = "${aws_vpc.main.id}"

  // ssh
  ingress {
    from_port   = "${var.ssh_port}"
    to_port     = "${var.ssh_port}"
    protocol    = "tcp"
    cidr_blocks = ["${var.ssh_cidr}"]
  }

  // https
  ingress {
    from_port   = "${var.https_port}"
    to_port     = "${var.https_port}"
    protocol    = "tcp"
    cidr_blocks = ["${var.https_cidr}"]
  }

  // open vpn tcp
  ingress {
    from_port   = "${var.tcp_port}"
    to_port     = "${var.tcp_port}"
    protocol    = "tcp"
    cidr_blocks = ["${var.tcp_cidr}"]
  }

  // open vpn udp
  ingress {
    from_port   = "${var.udp_port}"
    to_port     = "${var.udp_port}"
    protocol    = "udp"
    cidr_blocks = ["${var.udp_cidr}"]
  }

  // all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "route53_zone_name" {}
variable "subdomain_name" {}

variable "subdomain_ttl" {
  default = "60"
}

data "aws_route53_zone" "main" {
  name = "${var.route53_zone_name}"
}

resource "aws_route53_record" "vpn" {
  zone_id = "${data.aws_route53_zone.main.zone_id}"
  name    = "${var.subdomain_name}"
  type    = "A"
  ttl     = "${var.subdomain_ttl}"
  records = ["${aws_instance.openvpn.public_ip}"]
}

variable "ami" {
  default = "ami-f53d7386" // ubuntu xenial openvpn ami in eu-west-1
}

variable "instance_type" {
  default = "t2.medium"
}

variable "admin_user" {
  default = "openvpn"
}

variable "admin_password" {
  default = "openvpn"
}

resource "aws_instance" "openvpn" {
  tags {
    Name = "openvpn"
  }

  ami                         = "${var.ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${aws_key_pair.openvpn.key_name}"
  subnet_id                   = "${aws_subnet.vpn_subnet.id}"
  vpc_security_group_ids      = ["${aws_security_group.openvpn.id}"]
  associate_public_ip_address = true

  # `admin_user` and `admin_pw` need to be passed in to the appliance through `user_data`, see docs -->
  # https://docs.openvpn.net/how-to-tutorialsguides/virtual-platforms/amazon-ec2-appliance-ami-quick-start-guide/
  user_data = <<USERDATA
admin_user=${var.admin_user}
admin_pw=${var.admin_password}
USERDATA
}

variable "certificate_email" {}

resource "null_resource" "provision_openvpn" {
  triggers {
    subdomain_id = "${aws_route53_record.vpn.id}"
  }

  connection {
    type        = "ssh"
    host        = "${aws_instance.openvpn.public_ip}"
    user        = "${var.ssh_user}"
    private_key = "${var.private_key}"
    agent       = false
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get install -y curl vim libltdl7 python3 python3-pip python software-properties-common unattended-upgrades",
      "sudo add-apt-repository -y ppa:certbot/certbot",
      "sudo apt-get -y update",
      "sudo apt-get -y install python-certbot certbot",
      "sudo service openvpnas stop",
      "sudo certbot certonly --standalone --non-interactive --agree-tos --email ${var.certificate_email} --domains ${var.subdomain_name} --pre-hook 'service openvpnas stop' --post-hook 'service openvpnas start'",
      "sudo ln -s -f /etc/letsencrypt/live/${var.subdomain_name}/cert.pem /usr/local/openvpn_as/etc/web-ssl/server.crt",
      "sudo ln -s -f /etc/letsencrypt/live/${var.subdomain_name}/privkey.pem /usr/local/openvpn_as/etc/web-ssl/server.key",
      "sudo service openvpnas start",
    ]
  }
}
