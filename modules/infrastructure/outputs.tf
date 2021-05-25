output "vpc_id" {
    description = "vpc id"
    value = aws_vpc.vpc.id
}

output "subnets_ids" {
    description = "subnets ids"
    value = local.subnets_ids
}

output "rt_id" {
    description = "route table id"
    value = aws_vpc.vpc.default_route_table_id
}

output "igw_id" {
    description = "internet gateway id"
    value = aws_internet_gateway.igw.id
}

output "security_groups_ids" {
    description = "a map of the name and the id of a  securit group"
    value = local.security_groups_id_name_map
}