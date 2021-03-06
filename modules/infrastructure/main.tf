locals {
  subnets_ids = [for subnet in aws_subnet.subnets: subnet.id]
  security_groups_id_name_map = zipmap(
    [for sgName, options in var.security_groups : sgName],
    [for sg in aws_security_group.sgs : sg.id]
  )
  security_groups_rules = flatten(
    [for sgName, rules in var.security_groups: 
      [for rule in rules: merge(rule, {id = lookup(local.security_groups_id_name_map, sgName) })]
    ]
  )
}

resource "aws_vpc" "vpc" {
    cidr_block = var.cidr_block
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        environment = var.environment
        Name = format("%s-%s-vpc", var.org, var.environment )
    }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    environment = var.environment
    Name = format("%s-%s-igw", var.org, var.environment )
  }
}

resource "aws_main_route_table_association" "main_rt" {
  vpc_id = aws_vpc.vpc.id
  route_table_id = aws_vpc.vpc.default_route_table_id
}

resource "aws_route" "rt_all_route" {
  route_table_id = aws_vpc.vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_subnet" "subnets" {
  for_each = var.subnets

  vpc_id = aws_vpc.vpc.id
  cidr_block = each.value.cidr_block

  tags = {
    environment = var.environment
    Name = format("%s-%s-%s", var.org, var.environment, each.key)
  }
}

resource "aws_route_table_association" "rt_subnets_association" {
  count = length(local.subnets_ids)

  route_table_id = aws_vpc.vpc.main_route_table_id
  subnet_id = element(local.subnets_ids, count.index)
}

resource "aws_network_acl_rule" "network_acl_rules" {
  count = length(var.acl_rules)

  network_acl_id = aws_vpc.vpc.default_network_acl_id

  rule_number = element(var.acl_rules, count.index).rule_number
  egress = element(var.acl_rules, count.index).egress
  protocol = element(var.acl_rules, count.index).protocol
  rule_action = element(var.acl_rules, count.index).rule_action
  from_port = element(var.acl_rules, count.index).from_port 
  to_port = element(var.acl_rules, count.index).to_port  
  cidr_block = element(var.acl_rules, count.index).cidr_block  
}

resource "aws_security_group" "sgs" {
  for_each = var.security_groups

  vpc_id = aws_vpc.vpc.id
  name = format("%s-%s-%s-sg", var.org, var.environment, each.key)

  tags = {
    environment = var.environment
    Name = format("%s-%s-%s-sg", var.org, var.environment, each.key)
  }
}

resource "aws_security_group_rule" "sgs_rules" {
  count = length(local.security_groups_rules)

  security_group_id = element(local.security_groups_rules, count.index).id
  type = element(local.security_groups_rules, count.index).type
  from_port = element(local.security_groups_rules, count.index).from_port
  to_port = element(local.security_groups_rules, count.index).to_port
  protocol = element(local.security_groups_rules, count.index).protocol
  cidr_blocks = element(local.security_groups_rules, count.index).cidr_blocks
}

locals {
  public_servers_names = [for serverName, options in var.instances: serverName if options.public ]
  servers_name_ids_map = zipmap(
        [for instanceName, options in var.instances: instanceName],
        [for server in aws_instance.servers: server.id]
    )
}

resource "aws_eip" "eips" {
  count = length(local.public_servers_names)

  instance = lookup(
    local.servers_name_ids_map,
    element(local.public_servers_names, count.index)
  )
  vpc = true
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "servers" {
  for_each = var.instances
  
  ami = data.aws_ami.ubuntu.id
  instance_type = each.value.instance_type
  key_name = each.value.key_name
  subnet_id = local.subnets_ids[0]
  vpc_security_group_ids = [ lookup(local.security_groups_id_name_map, each.key) ]

  tags = {
    environment = var.environment
    Name = format("%s-%s-%s-server", var.org, var.environment, each.key)
  }
}