terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "infrastructure" {
  source = "../modules/infrastructure"

  environment = var.environment
  org = var.org
  cidr_block = "10.0.0.0/16"
  subnets = {
    primary = {
      cidr_block = "10.0.1.0/24"
    }
    secondary = {
      cidr_block = "10.0.2.0/24"
    }
  }
  acl_rules = [
    {
      rule_number = 20
      egress = false
      protocol = "tcp"
      rule_action = "allow"
      from_port = 443
      to_port = 443
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_number = 40
      egress = false
      protocol = "tcp"
      rule_action = "allow"
      from_port = 80
      to_port = 80
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_number = 60
      egress = false
      protocol = "tcp"
      rule_action = "allow"
      from_port = 22
      to_port = 22
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_number = 70
      egress = false
      protocol = "tcp"
      rule_action = "allow"
      from_port = 1024
      to_port = 65535
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_number = 90
      egress = false
      protocol = "-1"
      rule_action = "deny"
      from_port = -1
      to_port = -1
      cidr_block = "0.0.0.0/0"
    }
  ]
  security_groups = {
    web = [
      {
        type = "ingress"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        type = "ingress"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        type = "ingress"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        type = "egress"
        from_port = -1
        to_port = -1
        protocol= "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
  instances = {
    web = {
      public = true
      instance_type = "t2.micro"
      key_name = var.web_key_name
    }
  }
}
