provider "aws" {
    access_key = var.my_access_key
    secret_key = var.my_secret_key  
    region = var.aws_region
}
resource "aws_vpc" "dev-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "VPC-${var.env_prefix}"
    }
}
resource "aws_subnet" "subnet-1" {
    vpc_id = aws_vpc.dev-vpc.id //interpolation of vpc id from an already created vpc resource block
    cidr_block = var.subnet_cidr_block
    availability_zone = var.subnet1_availability_zone
    tags = {
        Name = "Subnet-1-${var.env_prefix}"
    }
}

resource "aws_internet_gateway" "Dev-vpc-ig"{
vpc_id = aws_vpc.dev-vpc.id
tags = {
    Name = "IG-Dev-VPC-${var.env_prefix}"
}
}

resource "aws_route_table" "vpc-route-table" {
    vpc_id = aws_vpc.dev-vpc.id
    route {
    cidr_block = "0.0.0.0/0" // We're proving an entry in our route table to allow traffic from anywhere access our vpc.
    //Also, we don't need to (& technically can't) define the vpc cidr block as it's added in the route table by default.
    gateway_id = aws_internet_gateway.Dev-vpc-ig.id // to allow our vpc to access the internet
  }
  tags = {
    Name = "Route Table-Dev-VPC-${var.env_prefix}"
}
    }

resource "aws_route_table_association" "route_table_subnet_association"{ // to associate subnet-1 with vpc-route-table
    subnet_id = aws_subnet.subnet-1.id
    route_table_id = aws_route_table.vpc-route-table.id
}

resource "aws_security_group" "my-app-sg" {
    name = "myapp-sg"
    vpc_id = aws_vpc.dev-vpc.id
    ingress {
        from_port = 22  //from and to are just for defining a range of ports but since we only want to open one port,
        to_port = 22   // we've defined value 22 for both
        protocol = "tcp"
        cidr_blocks = var.my_ip // IP addresses permitted to enter our security group through SSH
    }

    ingress {
        from_port = 8080  
        to_port = 8080   
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] // any IP addresses permitted to enter our security group through HTTP
    }

    egress {
        from_port = 0  // o means all protocols open for outbound
        to_port = 0   
        protocol = "-1"  // -1 means all protocols open for outbound
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
    Name = "Security Group-Dev-VPC-${var.env_prefix}"
}
}

data "aws_ami" "latest_linux_ami" { // This is because AWS AMI ID keeps changing, so w're capturing it here to be later used in instance resource block.
    most_recent = true
    owners = ["137112412989"] //this value can be found under ec2/Images/AMIs/search for AMI ID
}

output ami_id { //to print ami id after terraform apply
  value       = data.aws_ami.latest_linux_ami.id
}

resource "aws_key_pair" "ssh-key" {
    key_name = "MyTerraform_WebServer_Key"
    public_key = file (var.public_key_location)
}

resource "aws_instance" "web" {
    ami = data.aws_ami.latest_linux_ami.id //we need to specify the AMI ID here
    instance_type = var.inctance_type
    subnet_id = aws_subnet.subnet-1.id
    vpc_security_group_ids = [aws_security_group.my-app-sg.id]
    availability_zone = var.subnet1_availability_zone
    associate_public_ip_address = true //so that a public IP is assigned to this instance
    key_name = aws_key_pair.ssh-key.key_name
    user_data  = file ("userdate.sh")
    tags = {
    Name = "Nginx-Web-Server-${var.env_prefix}"
    }
 }                

 output "ec2_public_ip" {
    value = aws_instance.web.private_ip //got 'public ip' argument from command: terraform state show aws_instance.web
 }
 
/*resource "aws_s3_bucket" "my-new-S3-bucket" {
bucket = "my-bucket-vibhav1998"
acl = "private"
tags = {
Name = "My S3 Bucket"
Purpose = "Intro to Resource Blocks Lab"
}*/