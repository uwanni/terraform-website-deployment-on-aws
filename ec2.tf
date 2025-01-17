locals {
  common_vars = {
      default_region = var.default_region,
      instance_name = var.instance_name,
      key_pair_name = var.key_pair_name,
      elastic_ip_tag_name = var.elastic_ip_tag_name,
      security_group_name = var.security_group_name,
      db_name = var.db_name,
      db_user = var.db_user,
      db_pwd = var.db_pwd,
      bucket_name = var.bucket_name,
      bucket_object_key = var.bucket_object_key,
      bucket_object_path = var.bucket_object_path,
      git_username = var.git_username,
      git_repo_url = var.git_repo_url,
      git_branch = var.git_branch,
      project_folder = var.project_folder,
      server_name = var.server_name,
      nginx_conf_file = var.nginx_conf_file,
      user_and_group = var.user_and_group,
      git_access_token = data.aws_ssm_parameter.git_access_token.value
  }
}

#create the ec2 instance
resource "aws_instance" "web" {
  ami = "ami-xxxxxxxxxxxx"
  instance_type = "t3.medium"


  #user-data file
  user_data = templatefile("${path.module}/scripts/multipart_userdata.sh", {
    script_one = templatefile("${path.module}/scripts/1_script.sh", local.common_vars),
    script_two = templatefile("${path.module}/scripts/2_script.sh", local.common_vars),
    script_three = templatefile("${path.module}/scripts/3_script.sh", local.common_vars)
  })

  security_groups = [aws_security_group.terraform_sg.name]
  key_name = var.key_pair_name 

  tags = {
    Name = var.instance_name
  }

}


# Create a Route 53 record
resource "aws_route53_record" "web" {
  zone_id = "xxxxxxxxxxxxx" 
  name    = var.server_name   
  type    = "A"
  ttl     = "300"
  records = [aws_eip.web_ip.public_ip]
}

#AWS SSM parameter store
data "aws_ssm_parameter" "git_access_token" {
  name = "git_access_token"
}



#key-pair
resource "aws_key_pair" "terra-key-pair" {
key_name = var.key_pair_name 
public_key = tls_private_key.rsa.public_key_openssh
}
resource "tls_private_key" "rsa" {
algorithm = "RSA"
rsa_bits  = 4096
}
resource "local_file" "terra-key-pair" {
content  = tls_private_key.rsa.private_key_pem
filename = "terra-key-pair"
}



#security groups for ec2
resource "aws_security_group" "terraform_sg" {

    name = var.security_group_name
    description = "secuirity group for terraform instance"

  ingress {
    description = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.security_group_name 
  }

}


resource "aws_eip" "web_ip" {
  instance = aws_instance.web.id
  tags = {
    Name = var.elastic_ip_tag_name 
  }
}