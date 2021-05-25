variable "environment" {
    description = "target environment"
    type = string
    default = "stage"
}

variable "org" {
    description = "organization name"
    type = string
    default = "mariossimou"
}


variable "cidr_block" {
    description = "cidr block of the vpc"
    type = string
} 

variable "subnets" {
    description = "a map of subnets and their options"
    type = map
} 

variable "acl_rules" {
    description = "list of acl rules"
    type = list(object({
        rule_number = number
        egress = bool
        protocol = string
        rule_action = string
        from_port = number
        to_port = number
        cidr_block = string
    }))
}

variable "security_groups" {
    description = "a list of security groups"
    type = map
}