output "vpc_id" {
    description = "vpc id"
    value = module.infrastructure.vpc_id
}

output "subnets_ids" {
    description = "subnets ids"
    value = module.infrastructure.subnets_ids
}

output "igw_id" {
    description = "internet gateway id"
    value = module.infrastructure.igw_id
}

output "security_groups_ids" {
    description = "a map of the name and the id of a  securit group"
    value = module.infrastructure.security_groups_ids
}

output "instances_id" {
    description = "a map of instances names and ids"
    value = module.infrastructure.instances_id
}

output "instances_public_ips" {
    description = "a map of instances names and public ips"
    value = module.infrastructure.instances_public_ips
}