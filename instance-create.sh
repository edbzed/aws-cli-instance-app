#!/bin/bash

# AWS CLI profile and region
AWS_PROFILE="your_aws_profile"
AWS_REGION="us-east-1"

# EC2 instance parameters
INSTANCE_TYPE="t2.micro"
AMI_ID="ami-XXXXXXXXXXXXXXXXX"  # Replace with your desired AMI ID
KEY_NAME="your_key_pair_name"
SECURITY_GROUP_ID="sg-XXXXXXXXXXXXXXXXX"  # Replace with your security group ID
SUBNET_ID="subnet-XXXXXXXXXXXXXXXXX"      # Replace with your subnet ID

# Function to create an EC2 instance
create_instance() {
  instance_name="$1"
  aws ec2 run-instances \
    --profile "$AWS_PROFILE" \
    --region "$AWS_REGION" \
    --image-id "$AMI_ID" \
    --instance-type "$INSTANCE_TYPE" \
    --key-name "$KEY_NAME" \
    --security-group-ids "$SECURITY_GROUP_ID" \
    --subnet-id "$SUBNET_ID" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance_name}]"
}

# Function to terminate an EC2 instance by its name
terminate_instance() {
  instance_name="$1"
  instance_id=$(aws ec2 describe-instances --profile "$AWS_PROFILE" --region "$AWS_REGION" --filters "Name=tag:Name,Values=$instance_name" --query "Reservations[].Instances[0].InstanceId" --output text)
  if [ -n "$instance_id" ]; then
    aws ec2 terminate-instances --profile "$AWS_PROFILE" --region "$AWS_REGION" --instance-ids "$instance_id"
    echo "Terminating EC2 instance: $instance_name (Instance ID: $instance_id)"
  else
    echo "No EC2 instance found with the name: $instance_name"
  fi
}

# Main menu
while true; do
  clear
  echo "EC2 Instance Management"
  echo "1. Create EC2 Instance"
  echo "2. Terminate EC2 Instance"
  echo "3. Exit"
  read -p "Select an option (1/2/3): " choice

  case $choice in
    1)
      read -p "Enter a name for the new instance: " instance_name
      create_instance "$instance_name"
      read -p "Press Enter to continue..."
      ;;
    2)
      read -p "Enter the name of the instance to terminate: " instance_name
      terminate_instance "$instance_name"
      read -p "Press Enter to continue..."
      ;;
    3)
      echo "Exiting..."
      exit 0
      ;;
    *)
      echo "Invalid choice. Please select 1, 2, or 3."
      read -p "Press Enter to continue..."
      ;;
  esac
done
