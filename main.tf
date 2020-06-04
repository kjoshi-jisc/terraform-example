variable "name" {
    description = "A descriptive name for the resource"
    type = string
    default = "ai-playground-ec2"
}

variable "owner" {
    description = "The owner/creator of the resource"
    type = string
    default = "Kiran Joshi"
}

variable "project" {
    description = "The project the resource belongs to"
    type = string
    default = "ai-playground"
}

variable "region" {
    description = "AWS region"
    type = string
    default = "eu-west-1"
}

provider "aws" {
    region = var.region
}

data "aws_vpc" "default" {
    default = true
}

module "sec_group" {
    name = "${var.name}-sg"
    source = "scottwinkler/sg/aws"
    vpc_id = data.aws_vpc.default.id
    ingress_rules = [
        {
            # SSH
            port        = 22
            cidr_blocks = ["0.0.0.0/0"]
        },
        {
            # HTTP
            port        = 80
            cidr_blocks = ["0.0.0.0/0"]
        },
        {
            # HTTPS
            port        = 443
            cidr_blocks = ["0.0.0.0/0"]
        },
        {
            # EXAMPLE, FOR SOME WEBSERVER
            port        = 8080
            cidr_blocks = ["0.0.0.0/0"]
        }
    ]
}

resource "aws_instance" "instance" {
    ami = "ami-0701e7be9b2a77600"
    instance_type = "t2.micro"
    associate_public_ip_address = true
    vpc_security_group_ids = [module.sec_group.security_group.id]
    user_data = file("cloud-init.txt")
    tags = {
        Name = var.name
        Owner = var.owner
        Project = var.project
    }
}

output "config" {
    value = {
        ec2_public_ip = aws_instance.instance.public_ip
        ec2_public_dns = aws_instance.instance.public_dns
    }
}