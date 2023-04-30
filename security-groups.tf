##################################################################################
# Minimal Security Groups rules to allow SSH and RDP from your own Public IP
##################################################################################
# Allowing connections to internet
resource "aws_security_group" "allow-internet-from-my-vpc-resources" {
    name        = "${local.co_name}-${local.biz_name}-${local.env_name}-internal-internet-all-traffic-allow-rule"
    description = "Allow SSH from Internet to the Internal IP addresses on your VPC Network"
    vpc_id      = aws_vpc.main.id

    egress {
        description = "Allow Internet access from my VPC resources"
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name        = "${local.co_name}-${local.biz_name}-${local.env_name}-internal-internet-all-traffic-allow-rule"
        Description = "Managed by Terraform"
    }
}

# Allowing HTTP connections from the Internal VPC network.
resource "aws_security_group" "allow-http-from-internal" {
    name        = "${local.co_name}-${local.biz_name}-${local.env_name}-internal-internal-tcp-80-allow-rule"
    description = "Allow HTTP from Internal to the Internal IP addresses on your VPC Network"
    vpc_id      = aws_vpc.main.id

    ingress {
        description          = "Allow HTTP from the Internal IP addresses"
        from_port            = 80
        to_port              = 80
        protocol             = "tcp"
        security_groups      = ["${aws_security_group.allow-http-https-from-internet.id}"]
    }

    tags = {
        Name        = "${local.co_name}-${local.biz_name}-${local.env_name}-internal-internal-tcp-80-allow-rule"
        Description = "Managed by Terraform"
    }
}

# Allowing HTTP/HTTPS connections from Internet.
resource "aws_security_group" "allow-http-https-from-internet" {
    name        = "${local.co_name}-${local.biz_name}-${local.env_name}-internet-internal-tcp-80-443-allow-rule"
    description = "Allow HTTP/HTTPS from Internet to the Internal IP addresses on your VPC Network"
    vpc_id      = aws_vpc.main.id

    ingress {
        description      = "Allow HTTP from Internet"
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    ingress {
        description      = "Allow HTTPS from Internet"
        from_port        = 443
        to_port          = 443
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    egress {
        description = "Allow Internet access from my VPC resources"
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name        = "${local.co_name}-${local.biz_name}-${local.env_name}-internet-internal-tcp-80-443-allow-rule"
        Description = "Managed by Terraform"
    }
}