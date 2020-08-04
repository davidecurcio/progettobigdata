provider "aws" {
  profile = "default"
  region  = var.region
}

resource "aws_security_group" "test" {
  name = "security_groups"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "master" {
  tags = {
    Name = "master"
  }

  ami             = var.ami
  instance_type   = var.instance_type
  key_name        = var.private_key_name
  security_groups = ["security_groups"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = self.public_dns
  }

  provisioner "local-exec" {
    command = "sleep 30 && scp -o StrictHostKeyChecking=no -i ${var.private_key_path} ${var.private_key_path} ubuntu@${self.public_dns}:/home/ubuntu/.ssh"
  }

  provisioner "file" {
    source      = "./start_master.sh"
    destination = "/home/ubuntu/start_master.sh"
  }

  provisioner "file" {
    source      = "./master.sh"
    destination = "/home/ubuntu/master.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 777 start_master.sh",
      "chmod 777 master.sh",
      "./master.sh"
    ]
  }
}

resource "aws_instance" "slave1" {
  tags = {
    Name = "slave1"
  }
  ami             = var.ami
  instance_type   = var.instance_type
  key_name        = var.private_key_name
  security_groups = ["security_groups"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("key_bigdata.pem")
    host        = self.public_dns
  }

  provisioner "local-exec" {
    command = "sleep 30"
  }

  provisioner "file" {
    source      = "./slave.sh"
    destination = "/home/ubuntu/slave.sh"
  }

  provisioner "file" {
    source      = "./start_slave.sh"
    destination = "/home/ubuntu/start_slave.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 777 slave.sh",
      "./slave.sh ${aws_instance.master.public_dns}",
      "chmod 777 ./start_slave.sh"
    ]
  }
}

resource "aws_instance" "slave2" {
  tags = {
    Name = "slave2"
  }
  ami             = var.ami
  instance_type   = var.instance_type
  key_name        = var.private_key_name
  security_groups = ["security_groups"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("key_bigdata.pem")
    host        = self.public_dns
  }

  provisioner "local-exec" {
    command = "sleep 30"
  }

  provisioner "file" {
    source      = "./slave.sh"
    destination = "/home/ubuntu/slave.sh"
  }

  provisioner "file" {
    source      = "./start_slave.sh"
    destination = "/home/ubuntu/start_slave.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 777 slave.sh",
      "./slave.sh ${aws_instance.master.public_dns}",
      "chmod 777 ./start_slave.sh"
    ]
  }
}

resource "aws_instance" "kafka_broker_producer" {
  tags = {
    Name = "kafka_broker_producer"
  }
  ami             = var.ami
  instance_type   = var.instance_type
  key_name        = var.private_key_name
  security_groups = ["security_groups"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("key_bigdata.pem")
    host        = self.public_dns
  }

  provisioner "local-exec" {
    command = "sleep 30"
  }

  provisioner "file" {
    source      = "./kafka_broker_producer.sh"
    destination = "/home/ubuntu/kafka_broker_producer.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 777 kafka_broker_producer.sh",
      "./kafka_broker_producer.sh",
    ]
  }
}
