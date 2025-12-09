# Hybrid PII Service Infrastructure

이 프로젝트는 PII(개인식별정보)를 다루는 서비스에서 민감한 PII 데이터를 온프레미스 환경에 격리하고, 변동성이 큰 워크로드는 퍼블릭 클라우드(AWS)의 탄력성을 활용해 확장성을 확보하는 하이브리드 클라우드 인프라를 Terraform(IaC)으로 정의한 코드 베이스입니다.

또한 AWS ECS Fargate와 ECS Anywhere를 활용하여 단일 Control Plane에서 클라우드와 온프레미스 컨테이너 리소스를 통합적으로 운영·관리하는 아키텍처를 구현합니다.

## Architecture Overview

이 프로젝트는 \*\*단일 이미지 전략(Single Image Strategy)\*\*을 채택하여, 트래픽의 경로에 따라 로직이 분기되는 하이브리드 아키텍처를 구성합니다.


  * **Traffic Routing (ALB):**
      * `/pii/*`: VPN 터널을 통해 온프레미스 서버로 라우팅 (민감 정보 처리).
      * 그 외: **AWS Fargate**로 라우팅 (일반 비즈니스 로직).
  * **Compute:**
      * Cloud: AWS ECS Fargate (Serverless).
      * On-Prem: AWS ECS Anywhere (Existing VM 활용).
  * **Network:** AWS VPC와 온프레미스 네트워크 간 **Site-to-Site VPN** 연결.



## Prerequisites

이 프로젝트를 배포하기 위해 다음 환경과 도구가 필요합니다.

### 1\. Tools

  * [Terraform](https://www.terraform.io/downloads) (v1.0+)
  * [AWS CLI](https://aws.amazon.com/cli/) (configured with Administrator permissions)

### 2\. On-Premise Environment

사전에 구축된 온프레미스 VM들이 필요합니다.
각 사용자의 온프레미스 인프라 구성에 따라 구체적인 설정은 달라질 수 있습니다.

  * **Gateway VM:** StrongSwan 등으로 VPN 구성이 가능한 상태.
  * **App Server VM:** Docker가 설치되어 있고, 인터넷 아웃바운드(AWS API 호출)가 NAT VM을 통해 가능한 상태.
  * **Vault & DB:** 내부망 통신이 가능한 보안 스토리지 및 데이터베이스.


## Getting Started

### 1\. Clone Repository

```bash
git clone https://github.com/squatboy/hybrid-public-cloud-infra.git
cd hybrid-public-cloud-infra
```

### 2\. Configure Variables (`terraform.tfvars`)

`terraform.tfvars.example` 파일을 복사하여 `terraform.tfvars`를 생성하고, 환경에 맞는 값을 입력합니다.


### 3\. Deploy Infrastructure

Terraform을 초기화하고 인프라를 생성합니다.

```bash
# 초기화
terraform init

# 계획 확인
terraform plan

# 인프라 생성 (약 15~20분 소요)
terraform apply
```


## Post-Provisioning Setup

Terraform 배포가 완료되면 `Outputs`에 출력된 정보를 바탕으로 온프레미스 연결을 설정해야 합니다.
민감한 정보(PSK 등)를 포함한 전체 출력값 확인:
```bash
terraform output -json
```

### Step 1. VPN Configuration (`Gateway VM`)

Terraform Output의 `vpn_tunnel1_address`와 `vpn_tunnel1_preshared_key`를 사용하여 `Gateway VM` 설정을 갱신합니다.

1.  **/etc/ipsec.conf** (터널 엔드포인트 수정)

    ```conf
    conn aws-tunnel-1
        right = <OUTPUT_AWS_TUNNEL1_IP>
        ...
    ```

2.  **/etc/ipsec.secrets** (PSK 비밀키 수정) **[중요]**

    ```conf
    <ONPREM_PUBLIC_IP> <OUTPUT_AWS_TUNNEL1_IP> : PSK "<OUTPUT_VPN_PSK>"
    ```

3.  **서비스 재시작**

    ```bash
    sudo systemctl restart strongswan-starter
    sudo ipsec status # 'ESTABLISHED' 확인
    ```

### Step 2. Configure Routing (`App Server VM`)

AWS ALB의 헬스체크 및 트래픽이 정상적으로 돌아올 수 있도록, 앱 서버(`App Server VM`)에 AWS VPC 대역으로 가는 정적 경로를 추가해야 합니다.

```bash
# App Server VM Terminal
# 예: AWS VPC(10.20.0.0/16) 트래픽은 Gateway VM(10.10.10.30)으로 보냄
sudo ip route add 10.20.0.0/16 via 10.10.10.30 dev eth0
```

### Step 3. Register On-Premise Server (`App Server VM`)

Terraform Output의 `ecs_anywhere_registration_command` 전체를 복사하여 온프레미스 앱 서버에서 실행합니다.

*(기존에 등록된 에이전트가 있다면 삭제 후 재등록을 권장합니다)*

```bash
# App Server VM Terminal
sudo bash /tmp/ecs-anywhere-install.sh \
  --cluster prod-pii-cluster \
  --activation-id <OUTPUT_ACTIVATION_ID> \
  --activation-code <OUTPUT_ACTIVATION_CODE> \
  --region ap-northeast-2
```

### Step 4. Activate Service

등록이 완료되고 ECS 콘솔에서 인스턴스가 확인되면, Terraform 변수 `ecs_onprem_desired_count`를 `1`로 변경하고 다시 적용하여 서비스를 시작합니다.

```bash
# terraform.tfvars 수정 (ecs_onprem_desired_count = 1) 후
terraform apply
```

## Application Deployment

이 레포지토리는 **인프라스트럭처**만 관리합니다. 실제 애플리케이션 코드는 별도의 레포지토리에서 관리됩니다. 참고: [`hybrid-pii-service-poc`](https://github.com/squatboy/hybrid-pii-service-poc) 

### 배포 파이프라인 (CI/CD)

애플리케이션 레포지토리에서 CI/CD 파이프라인을 통해 배포가 이루어집니다.

#### 권장하는 파이프라인:
1.  **OIDC 인증:** 이 인프라에서 생성된 `github_actions_role_arn`을 사용합니다.
2.  **Build:** Docker 이미지를 빌드하여 ECR에 푸시합니다.
3.  **Deploy:** AWS ECS `update-service` 명령을 통해 클라우드(Fargate)와 온프레미스(External) 서비스를 동시에 업데이트합니다.


## Clean Up

리소스 삭제 시 다음 순서로 진행하여 비용 발생을 방지하세요.

```bash
# 1. 인프라 삭제
terraform destroy

# 2. (On-Prem Server) 에이전트 클린업
# App Server VM에서 실행
sudo systemctl stop amazon-ecs-init amazon-ssm-agent
sudo apt-get remove --purge amazon-ecs-init amazon-ssm-agent
sudo rm -rf /var/lib/ecs /var/lib/amazon /etc/ecs
```