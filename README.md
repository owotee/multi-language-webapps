# Terraform AWS Infrastructure as Code Project

This project provisions a complete AWS multi-tier environment using Terraform. The infrastructure includes networking, compute, and database resources configured entirely through Infrastructure as Code (IaC).

The goal of this project is to demonstrate how Terraform can be used to automate AWS infrastructure deployment in a repeatable, scalable, and organized way.

---

# Project Objective

This Terraform project provisions:

- 1 VPC
- 1 public subnet
- 2 private subnets
- 1 Internet Gateway
- 1 public route table
- 2 EC2 instances in the public subnet
- 1 RDS MySQL instance in private subnets
- Security groups for EC2 and RDS
- Terraform outputs for important resource information

The architecture follows a simple multi-tier AWS design where EC2 instances act as web/application servers and RDS acts as the backend database layer.

---

# Architecture Diagram

``
                            +----------------------+
                            |   Terraform Control  |
                            |      Machine (EC2)   |
                            | AWS CLI + Terraform  |
                            +----------+-----------+
                                       |
                                       | terraform apply
                                       v
+----------------------------------------------------------------------------------+
|                                     AWS Cloud                                    |
|                                                                                  |
|  +-------------------------------------------------------------------------+     |
|  |                                 VPC                                      |     |
|  |                            10.0.0.0/16                                   |     |
|  |                                                                         |     |
|  |   +---------------------------+         +----------------------------+   |     |
|  |   |      Public Subnet        |         |     Private Subnet A       |   |     |
|  |   |       10.0.1.0/24         |         |       10.0.4.0/24          |   |     |
|  |   |                           |         |                            |   |     |
|  |   |   +-------------------+   |         |                            |   |     |
|  |   |   |    EC2 Instance 1 |   |         |                            |   |     |
|  |   |   |   Web/App Server  |   |         |                            |   |     |
|  |   |   +-------------------+   |         |                            |   |     |
|  |   |                           |         |                            |   |     |
|  |   |   +-------------------+   |         +----------------------------+   |     |
|  |   |   |    EC2 Instance 2 |   |                                          |     |
|  |   |   |   Web/App Server  |   |         +----------------------------+   |     |
|  |   |   +-------------------+   |         |     Private Subnet B       |   |     |
|  |   |                           |         |       10.0.3.0/24          |   |     |
|  |   +-------------+-------------+         |                            |   |     |
|  |                 |                       |   +--------------------+   |   |     |
|  |                 |                       |   |     RDS MySQL      |   |   |     |
|  |                 |                       |   |   Private Database |   |   |     |
|  |                 |                       |   +--------------------+   |   |     |
|  |                 |                       +----------------------------+   |     |
|  |                 |                                                       |     |
|  |         +-------v--------+                                              |     |
|  |         | Internet       |                                              |     |
|  |         | Gateway        |                                              |     |
|  |         +----------------+                                              |     |
|  |                                                                         |     |
|  +-------------------------------------------------------------------------+     |
|                                                                                  |
+----------------------------------------------------------------------------------+

Traffic Flow:
- Users connect to EC2 instances over HTTP and HTTPS
- Administrators connect to EC2 instances over SSH
- EC2 instances connect to RDS over MySQL port 3306
- RDS is private and not accessible directly from the internet

- PROJECT STRUCTURE
- terraform-aws-iac/
├── main.tf
├── network.tf
├── security.tf
├── ec2.tf
├── rds.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
├── README.md
└── .gitignore


File Descriptions
main.tf
Contains the Terraform provider configuration and common local values.
network.tf
Creates the VPC, subnets, Internet Gateway, route table, and route table associations.
security.tf
Creates the EC2 and RDS security groups.
ec2.tf
Creates two EC2 instances in the public subnet.
rds.tf
Creates the RDS MySQL instance and DB subnet group.
variables.tf
Declares all variables used in the project.
terraform.tfvars
Stores the values assigned to Terraform variables.
outputs.tf
Displays important information after deployment.
README.md
Contains the project documentation.
.gitignore
Prevents sensitive files and Terraform state files from being uploaded to GitHub.
Resources Created
Networking Resources
1 VPC
1 public subnet
2 private subnets
1 Internet Gateway
1 route table
1 route table association
Security Resources
1 EC2 security group
1 RDS security group
Compute Resources
2 EC2 instances
Database Resources
1 RDS MySQL instance
1 DB subnet group
Security Configuration
EC2 Security Group

The EC2 security group allows inbound traffic for:

SSH on port 22
HTTP on port 80
HTTPS on port 443

It allows outbound traffic to all destinations.

RDS Security Group

The RDS security group allows inbound traffic for:

MySQL on port 3306

The source for MySQL traffic is restricted to the EC2 security group only.

This prevents the database from being publicly accessible.

Prerequisites

Before running this project, the following tools must be installed on the control machine:

Terraform
AWS CLI
Git

The AWS account used must have permission to create:

VPC resources
Subnets
Internet Gateway
Route tables
EC2 instances
Security groups
RDS resources
DB subnet groups
Control Machine Setup

This project uses an EC2 instance as the Terraform control machine.

Example installation steps for Amazon Linux:

sudo yum update -y
sudo yum install -y git unzip awscli

curl -LO https://releases.hashicorp.com/terraform/1.7.5/terraform_1.7.5_linux_amd64.zip
unzip terraform_1.7.5_linux_amd64.zip
sudo mv terraform /usr/local/bin/

terraform -v
aws --version
git --version
Clone the Repository
git clone https://github.com/your-username/terraform-aws-iac.git
cd terraform-aws-iac
Terraform Initialization

Initialize Terraform:

terraform init

Format Terraform files:

terraform fmt

Validate Terraform configuration:

terraform validate

Review the Terraform execution plan:

terraform plan

Deploy the infrastructure:

terraform apply

When prompted, type:

yes

Destroy the infrastructure when finished:

terraform destroy
Terraform Variables

Example terraform.tfvars file:

aws_region        = "us-east-1"
project_name      = "iac-assignment"
environment       = "dev"

key_pair_name     = "IAC_Project"
instance_type     = "t2.micro"

allowed_ssh_cidr  = "0.0.0.0/0"

db_name           = "appdb"
db_username       = "admin"
db_password       = "ChangeMe123!"
db_instance_class = "db.t3.micro"

Important:

Do not commit terraform.tfvars to GitHub
Do not commit passwords or AWS secrets
Use lowercase names for project and environment values
Terraform Outputs

After deployment, Terraform provides outputs such as:

VPC ID
public subnet ID
private subnet IDs
EC2 public IPs
EC2 public DNS names
RDS endpoint
RDS port

To display outputs:

terraform output

Example output:

ec2_public_ips = [
  "44.200.xxx.xxx",
  "100.48.xxx.xxx"
]

rds_endpoint = "iac-assignment-dev-db.xxxxxxxxx.us-east-1.rds.amazonaws.com:3306"
How to Access EC2 Instances

Use the private key that matches the AWS key pair used in terraform.tfvars.

Example:

ssh -i /path/to/IAC_Project.pem ec2-user@<ec2-public-ip>

Example with Windows WSL:

ssh -i "/mnt/c/Users/YourName/Downloads/IAC Project.pem" ec2-user@44.200.xxx.xxx

Replace:

/path/to/IAC_Project.pem
<ec2-public-ip>

with the actual values.

How to Test the Web Server

After deployment, test the EC2 instances by opening the public IP in a browser:

http://<ec2-public-ip>

You can also test from the terminal:

curl http://<ec2-public-ip>

If Apache is installed and running, the browser should display a simple HTML page.

To install and start Apache manually:

sudo dnf install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd
echo "<h1>Terraform Web Server is working</h1>" | sudo tee /var/www/html/index.html

To verify Apache:

sudo systemctl status httpd
curl http://localhost
How to Test RDS Connectivity

SSH into one of the EC2 instances and run:

mysql -h <rds-endpoint> -u admin -p

Then enter the database password.

This confirms:

the EC2 instance can reach the RDS database
the RDS security group allows MySQL traffic from EC2 only
Git Setup

Initialize Git:

git init

Add all files:

git add .

Commit the files:

git commit -m "Initial Terraform AWS IaC project"

Create a GitHub repository and connect it:

git branch -M main
git remote add origin https://github.com/your-username/terraform-aws-iac.git
git push -u origin main
Recommended .gitignore
.terraform/
*.tfstate
*.tfstate.*
terraform.tfvars
*.pem
*.zip
.crash.log
Common Issues Encountered
IAM Permission Errors

Terraform may fail if the EC2 control machine does not have permission to create AWS resources.

Solution:

Attach an IAM role to the EC2 control machine
Use policies such as:
AmazonEC2FullAccess
AmazonRDSFullAccess
Invalid RDS Identifier Names

AWS RDS identifiers only allow lowercase letters, numbers, and hyphens.

Use values like:

iac-assignment-dev-db

Do not use spaces or special characters.

RDS Requires Multiple Availability Zones

RDS subnet groups require subnets in at least two Availability Zones.

Solution:

Create two private subnets
Put them in different Availability Zones
Use both subnets in the DB subnet group
SSH Key Pair Problems

SSH will fail if:

the wrong key pair name is used
the .pem file does not exist
the .pem file has incorrect permissions

Correct permissions:

chmod 400 /path/to/key.pem
Browser Page Not Loading

Possible causes:

Apache not installed
Apache not running
Port 80 blocked in security group
wrong EC2 public IP used
Future Improvements

Possible future improvements include:

Application Load Balancer
Auto Scaling Group
NAT Gateway
Bastion Host
S3 backend for Terraform state
DynamoDB state locking
CloudWatch monitoring
Route 53 DNS
HTTPS with ACM certificates
CI/CD using GitHub Actions
Conclusion

This project demonstrates how Terraform can be used to provision AWS infrastructure using Infrastructure as Code principles. The environment includes networking, compute, security, and database resources. Using Terraform makes infrastructure easier to deploy, document, manage, and reproduce.
