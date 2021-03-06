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

variable "region" {
    description = "aws region"
    type = string
}

variable "web_key_name" {
    description = "key name of the web server"
    type = string
}