# Terraform + AWS: highly available web app behind an ALB

Infrastructure as Code project that provisions a public web tier on AWS with
Terraform: a custom VPC, two public subnets across two Availability Zones, two
EC2 web servers bootstrapped with Apache via user data, and an Application Load
Balancer distributing traffic between them.

## Architecture

```
Internet
   |
Internet Gateway
   |
Application Load Balancer (listener :80)
   |
Target Group (health check on /)
   |-- EC2 webserver1  (subnet sub1, us-east-1a)
   `-- EC2 webserver2  (subnet sub2, us-east-1b)

S3 bucket (regional, outside the VPC)
```

## What this project creates

| Layer | Resources |
|---|---|
| Network | VPC (`10.0.0.0/16`), 2 public subnets (`/24`), Internet Gateway, route table + 2 associations |
| Security | Security group allowing HTTP (80) and SSH (22) inbound, all outbound |
| Compute | 2 x EC2 `t3.micro` running Ubuntu 24.04, Apache installed via `userdata.sh` |
| Load balancing | Application Load Balancer, target group with health checks, HTTP listener |
| Storage | S3 bucket |
| Output | ALB DNS name |

Each web server shows its own instance ID, so refreshing the ALB URL shows
traffic alternating between the two servers.

## Files

| File | Purpose |
|---|---|
| `provider.tf` | Terraform + AWS provider settings (region `us-east-1`) |
| `variables.tf` | VPC CIDR and S3 bucket name inputs |
| `main.tf` | All infrastructure resources and the ALB DNS output |
| `userdata.sh` | Boot script: installs Apache, writes a page with the instance ID (IMDSv2) |
| `.terraform.lock.hcl` | Pins provider versions for reproducible runs |

## Prerequisites

- Terraform >= 1.5
- AWS CLI configured (`aws configure`) with an IAM user, not root
- Region: `us-east-1`

## Usage

```bash
terraform init
terraform plan  -var="bucket_name=<your-unique-bucket-name>"
terraform apply -var="bucket_name=<your-unique-bucket-name>"
```

Open the `loadbalancerdns` output in a browser using `http://`. Allow 2-3
minutes for health checks to pass after apply.

## Clean up

```bash
terraform destroy -var="bucket_name=<your-unique-bucket-name>"
```

The ALB bills hourly, so destroy when finished.

## Notes

- AWS accounts created on or after July 15, 2025 cannot launch `t2.micro` on
  the Free plan; this project uses `t3.micro`.
- The AMI ID is region-specific (us-east-1, Ubuntu 24.04 amd64).
- SSH is open to `0.0.0.0/0` for learning purposes; restrict it to your own IP
  for anything real.
- State files are git-ignored: they contain account IDs and resource details.

## Tech

Terraform, AWS (VPC, EC2, ALB, S3, IAM), Bash, Apache
