provider "aws" {
    access_key = var.my_access_key
    secret_key = var.my_secret_key  
    region = var.aws_region
}

resource "aws_vpc" "dev-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "dev-vpc"
    }
}

resource "aws_subnet" "private-subnet" {
    vpc_id = aws_vpc.dev-vpc.id //interpolation of vpc id from an already created vpc resource block
    cidr_block = "10.0.10.0/24"
    availability_zone = var.private-subnet_availability_zone
    
}

data "aws_vpc" "default_vpc" {
  default = true
}

resource "aws_subnet" "subnet-1" { 
    vpc_id = data.aws_vpc.default_vpc.id //interpolation from the vpc created above using data block.
    cidr_block = "172.31.48.0/20" // IP taken randomly after the last subnet IP in my account under region eu-west-1
}

output "vpc-id-output" {
  value       = aws_vpc.dev-vpc.id
  sensitive   = false
  description = "description"
}

/*resource "aws_instance" "web" {
 ami = "ami-0d04e6652cb408e57"
 instance_type = "t2.micro"
 subnet_id = "<SUBNET>"
 vpc_security_group_ids = ["<SECURITY_GROUP>"]
 tags = {
 "Identity" = "<IDENTITY>"
 }
 }*/

/*resource "aws_s3_bucket" "my-new-S3-bucket" {
bucket = "my-bucket-vibhav1998"
acl = "private"
tags = {
Name = "My S3 Bucket"
Purpose = "Intro to Resource Blocks Lab"
}*/