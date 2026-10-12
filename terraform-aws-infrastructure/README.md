# Terraform AWS Infrastructure: VPC, Multi-AZ EC2 & Application Load Balancer

## 📌 Project Overview

This is my first Infrastructure as Code (IaC) project using **Terraform and AWS**. The objective was to provision a basic, highly available web infrastructure by defining AWS resources in Terraform configuration files instead of creating them manually through the AWS Management Console.

The project creates a custom VPC, deploys two EC2 instances across two Availability Zones, configures an Application Load Balancer (ALB), and executes a startup script on each EC2 instance to configure the application automatically during launch.

## 🏗️ Architecture

```text
                   Internet
                       |
                       v
              Application Load
                 Balancer
                       |
              +--------+--------+
              |                 |
              v                 v
        EC2 Instance 1     EC2 Instance 2
          AZ-1                AZ-2
              |                 |
         Startup Script    Startup Script
              |                 |
              v                 v
        Web Application    Web Application

       All resources deployed within
             a custom AWS VPC
```

## 🚀 Deployment Steps

### Prerequisites

- An AWS account with the required permissions.
- Terraform CLI installed.
- AWS CLI installed and configured with appropriate credentials.
- Git installed.

### Step 1: Clone the repository

```bash
git clone <GitHub_URL>
cd terraform-aws-infrastructure
```

### Step 2: Initialize Terraform

```bash
terraform init
```

Downloads the required Terraform providers and initializes the working directory.

### Step 3: Validate the configuration

```bash
terraform fmt
terraform validate
```

Formats the Terraform configuration and checks its validity.

### Step 4: Review the execution plan

```bash
terraform plan
```

Previews the infrastructure changes Terraform intends to make.

### Step 5: Provision the infrastructure

```bash
terraform apply
```

Review the proposed changes and confirm the deployment when prompted.

### Step 6: Test the application

Retrieve the Application Load Balancer DNS name from Terraform outputs or the AWS Console.

Open the DNS name in a browser using HTTP. Verify that the application responds and that both EC2 instances are healthy in the target group.

### Step 7: Clean up resources

```bash
terraform destroy
```

Review and confirm before destroying the resources to avoid unnecessary AWS charges.

## 📚 Key Learnings

Through this project, I gained practical experience with:

- Infrastructure as Code using Terraform.
- Defining and managing AWS resources declaratively.
- Understanding VPCs, subnets, route tables, and security groups.
- Deploying EC2 instances across multiple Availability Zones.
- Configuring an Application Load Balancer and target groups.
- Automating server setup using EC2 user data.
- Using Terraform initialization, validation, planning, deployment, and cleanup commands.
- Understanding how networking, compute, and load balancing work together in AWS.

## 👨‍💻 Author

Built as my first hands-on Terraform project to strengthen my understanding of AWS infrastructure, networking, compute, load balancing, and Infrastructure as Code.