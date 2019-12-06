# Configure the AWS Provider
provider "aws" {
  access_key = "AKIATSAO44MRNBZZDAUO"
  secret_key = "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"
  region     = "us-gov-east-1"
}

resource "aws_instance" "k8s" {
  ami = "ami-0455d8819e31951ca"
  instance_type = "t3.large"
  vpc_security_group_ids = ["sg-0ef88586c2f6ea71a"]
  key_name = "k8s"
  count = 3
  ebs_block_device {
    device_name = "/dev/xvdb"
    volume_size = 25
    volume_type = "gp2"
    delete_on_termination = false
         }
  user_data = <<-EOF
              #! /bin/bash
              yum update -y
              setenforce 0
              sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
              systemctl stop firewalld
              systemctl disable firewalld
              yum install -y yum-utils device-mapper-persistent-data lvm2
              yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
              yum install -y docker-ce-18.06.2.ce
              EOF
  tags = {
    Name = "k8s ${count.index}"}
    }

  output "instance_ip_addr" {
    value = aws_instance.k8s.0.public_ip
 }
  