### 🇰🇷 [한국어 보기](README.ko.md)

# Hybrid PII Service Infrastructure

This project is a codebase defined with Terraform(IaC) for a **hybrid cloud infrastructure**. It isolates sensitive PII data within an on-premise environment for services handling PII (Personally Identifiable Information), while securing scalability by utilizing the elasticity of the public cloud (AWS) for highly volatile workloads.

Additionally, it implements an architecture that integrates the operation and management of cloud and on-premise container resources under a single Control Plane by utilizing **AWS ECS Fargate and ECS Anywhere**.

## Architecture Overview

This project adopts a **Single Image Strategy** to configure a hybrid architecture where logic branches based on traffic paths.


  * **Traffic Routing (ALB):**
      * `/pii/*`: Routed to the on-premise server via VPN tunnel (Sensitive data processing).
      * Others: Routed to **AWS Fargate** (General business logic).
  * **Compute:**
      * Cloud: AWS ECS Fargate (Serverless).
      * On-Prem: AWS ECS Anywhere (Existing VM utilization).
  * **Network:** **Site-to-Site VPN** connection between AWS VPC and on-premise network.



## Prerequisites

The following environments and tools are required to deploy this project.

### 1\. Tools

  * [Terraform](https://www.terraform.io/downloads) (v1.0+)
  * [AWS CLI](https://aws.amazon.com/cli/) (configured with Administrator permissions)

### 2\. On-Premise Environment

Pre-configured on-premise VMs are required.
Specific configurations may vary depending on each user's on-premise infrastructure setup.

  * **Gateway VM:** Capable of configuring VPN with StrongSwan, etc.
  * **App Server VM:** Docker installed, and outbound internet access (AWS API calls) is possible via the NAT VM.
  * **Vault & DB:** Secure storage and database capable of internal network communication.


## Getting Started

### 1\. Clone Repository

```bash
git clone https://github.com/squatboy/hybrid-public-cloud-infra.git
cd hybrid-public-cloud-infra
````

### 2\. Configure Variables (`terraform.tfvars`)

Copy the `terraform.tfvars.example` file to create `terraform.tfvars`, and enter values appropriate for your environment.

### 3\. Deploy Infrastructure

Initialize Terraform and create the infrastructure.

```bash
# Initialize
terraform init

# Check Plan
terraform plan

# Create Infrastructure (Takes about 15~20 mins)
terraform apply
```

## Post-Provisioning Setup

Once the Terraform deployment is complete, you must configure the on-premise connection based on the information printed in `Outputs`.

Check full output including sensitive information (PSK, etc.):

```bash
terraform output -json
```

### Step 1. VPN Configuration (`Gateway VM`)

Update the `Gateway VM` configuration using `vpn_tunnel1_address` and `vpn_tunnel1_preshared_key` from the Terraform Output.

1.  **/etc/ipsec.conf** (Modify tunnel endpoint)

    ```conf
    conn aws-tunnel-1
        right = <OUTPUT_AWS_TUNNEL1_IP>
        ...
    ```

2.  **/etc/ipsec.secrets** (Modify PSK secret key) **[Important]**

    ```conf
    <ONPREM_PUBLIC_IP> <OUTPUT_AWS_TUNNEL1_IP> : PSK "<OUTPUT_VPN_PSK>"
    ```

3.  **Restart Service**

    ```bash
    sudo systemctl restart strongswan-starter
    sudo ipsec status # Check 'ESTABLISHED'
    ```

### Step 2. Configure Routing (`App Server VM`)

To ensure AWS ALB health checks and traffic return normally, you must add a static route to the AWS VPC range on the app server (`App Server VM`).

```bash
# App Server VM Terminal
# Example: Send AWS VPC (10.20.0.0/16) traffic to Gateway VM (10.10.10.30)
sudo ip route add 10.20.0.0/16 via 10.10.10.30 dev eth0
```

### Step 3. Register On-Premise Server (`App Server VM`)

Copy the entire `ecs_anywhere_registration_command` from the Terraform Output and execute it on the on-premise app server. This script installs the SSM Agent and ECS Agent and registers the server to the cluster.

*(If an agent is already registered, it is recommended to delete and re-register it)*

```bash
# App Server VM Terminal
sudo bash /tmp/ecs-anywhere-install.sh \
  --cluster prod-pii-cluster \
  --activation-id <OUTPUT_ACTIVATION_ID> \
  --activation-code <OUTPUT_ACTIVATION_CODE> \
  --region ap-northeast-2
```

### Step 4. Activate Service

Once registration is complete and the instance is verified in the ECS console, change the Terraform variable `ecs_onprem_desired_count` to `1` and re-apply to start the service.

```bash
# After modifying terraform.tfvars (ecs_onprem_desired_count = 1)
terraform apply
```

## Application Deployment

This repository manages **infrastructure** only. Actual application code is managed in a separate repository. Reference: [`hybrid-pii-service-poc`](https://github.com/squatboy/hybrid-pii-service-poc)

### Deployment Pipeline (CI/CD)

Deployment is performed via the CI/CD pipeline in the application repository.

#### Recommended Pipeline:

1.  **OIDC Authentication:** Use `github_actions_role_arn` created in this infrastructure.
2.  **Build:** Build Docker image and push to ECR.
3.  **Deploy:** Update both Cloud (Fargate) and On-Premise (External) services simultaneously using the AWS ECS `update-service` command.

## Clean Up

When deleting resources, proceed in the following order to prevent costs.

```bash
# 1. Delete Infrastructure
terraform destroy

# 2. (On-Prem Server) Agent Cleanup
# Run on App Server VM
sudo systemctl stop amazon-ecs-init amazon-ssm-agent
sudo apt-get remove --purge amazon-ecs-init amazon-ssm-agent
sudo rm -rf /var/lib/ecs /var/lib/amazon /etc/ecs
```
