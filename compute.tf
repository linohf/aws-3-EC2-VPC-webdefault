##################################################################################
# DATA  
##################################################################################
data "aws_ami" "amazon-linux-2" {
    most_recent =   true
    owners      =   ["amazon"]

    filter {
        name    =   "name"
        values  =   ["amzn2-ami-hvm*"]
    }

    filter {
        name    =   "root-device-type"
        values  =   ["ebs"]
    }

    filter {
        name    =   "virtualization-type"
        values  =   ["hvm"]
    }
}

##################################################################################
# RESOURCES  
##################################################################################
resource "aws_instance" "website" {
    count                       =   var.vm_count[terraform.workspace]
    ami                         =   data.aws_ami.amazon-linux-2.id
    instance_type               =   "t2.micro"
    subnet_id                   =   aws_subnet.private[count.index].id
    vpc_security_group_ids      =   [ aws_security_group.allow-http-from-internal.id, aws_security_group.allow-internet-from-my-vpc-resources.id ]
    iam_instance_profile        =   aws_iam_instance_profile.aws_ec2_ssm_instance_profile.name
    user_data = <<EOF
        #!/bin/bash
        echo "Changing Hostname"
        hostnamectl set-hostname "${local.co_name}-${local.biz_name}-${local.env_name}-vm-${count.index + 1}"
        echo "${local.co_name}-${local.biz_name}-${local.env_name}-vm-${count.index + 1}" > /etc/hostname
        echo "Installing httpd"
        sudo yum update -y
        sudo yum install httpd -y
        sudo systemctl enable httpd
        sudo systemctl start httpd
        echo '<h1>Welcome to my website! LinoHF</h1>' | sudo tee /var/www/html/index.html
        EOF

    tags = {
       Name = "${local.co_name}-${local.biz_name}-${local.env_name}-vm-${count.index + 1}"
       Delivery = "DevOps"
       Description = "Managed by Terraform" 
    }
  
}

# LOAD BALANCER #
resource "aws_lb" "website-alb" {
    count               =   var.vm_count[terraform.workspace]
    name                =   "${local.co_name}-${local.biz_name}-${local.env_name}-lb-${count.index + 1}"
    internal            =   false
    load_balancer_type  =   "application"
    security_groups     =   [aws_security_group.allow-http-https-from-internet.id]
    subnets             =   [for subnet in aws_subnet.public : subnet.id]

    tags = {
       Name = "${local.co_name}-${local.biz_name}-${local.env_name}-lb-${count.index + 1}"
       Description = "Managed by Terraform" 
    }
  
}

resource "aws_lb_target_group" "website-alb-tg" {
  name     = "website-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "website-alb-tg-instance" {
  count            = var.vm_count[terraform.workspace]
  target_group_arn = aws_lb_target_group.website-alb-tg.arn
  target_id        = aws_instance.website[count.index].id
  port             = 80
}

resource "aws_lb_listener" "website-alb-frontend" {
  count               =   var.vm_count[terraform.workspace]
  load_balancer_arn = aws_lb.website-alb[count.index].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.website-alb-tg.arn
  }
}

##################################################################################
# OUTPUT  
##################################################################################