aws_region        = "us-east-1"
project_name      = "iac-assignment"
environment       = "dev"

key_pair_name     = "IAC Project"
instance_type     = "t3.micro"

allowed_ssh_cidr  = "0.0.0.0/0"

db_name           = "appdb"
db_username       = "admin"
db_password       = ""
db_instance_class = "db.t3.micro"
