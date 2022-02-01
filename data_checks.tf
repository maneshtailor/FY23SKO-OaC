
# Check if we can get access to our New Relic account
data "newrelic_account" "account" {
  scope = "global"
}

# Check if we have access to our AWS account
data "aws_ec2_instance_type" "example" {
  instance_type = "t2.micro"
}

