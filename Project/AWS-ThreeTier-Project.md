# WellNest — AWS 3-Tier Architecture Deployment

<div align="center">

![WellNest Banner](https://img.shields.io/badge/WellNest-Mental%20Health%20Platform-4CAF50?style=for-the-badge&logo=heart&logoColor=white)

[![AWS](https://img.shields.io/badge/AWS-Cloud%20Infrastructure-FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com)
[![MongoDB](https://img.shields.io/badge/MongoDB-7.0-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://www.mongodb.com)
[![Node.js](https://img.shields.io/badge/Node.js-20.x-339933?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org)
[![React](https://img.shields.io/badge/React-Vite-61DAFB?style=for-the-badge&logo=react&logoColor=white)](https://react.dev)
[![NGINX](https://img.shields.io/badge/NGINX-Reverse%20Proxy-009639?style=for-the-badge&logo=nginx&logoColor=white)](https://nginx.org)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](LICENSE)

**A production-grade, enterprise-level mental health platform deployed on AWS using a secure 3-tier microservices architecture.**

[Architecture](#architecture) • [Features](#features) • [Services](#service-map) • [Deployment](#deployment-guide) • [Security](#security) • [Auto Scaling](#auto-scaling)

</div>

---

## Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Features](#features)
- [Service Map](#service-map)
- [Infrastructure Components](#infrastructure-components)
- [Deployment Guide](#deployment-guide)
  - [Step 1 — VPC](#step-1--create-vpc)
  - [Step 2 — Internet Gateway](#step-2--internet-gateway)
  - [Step 3 — Subnets](#step-3--subnets)
  - [Step 4 — NAT Gateway](#step-4--nat-gateway)
  - [Step 5 — Route Tables](#step-5--route-tables)
  - [Step 6 — Security Groups](#step-6--security-groups)
  - [Step 7 — Bastion Host](#step-7--bastion-host)
  - [Step 8 — Database EC2](#step-8--database-ec2)
  - [Step 9 — MongoDB Setup](#step-9--mongodb-setup)
  - [Step 10 — App Tier Instance](#step-10--app-tier-instance)
  - [Step 11 — Backend Deployment](#step-11--backend-deployment)
  - [Step 12 — Internal ALB](#step-12--internal-alb--target-groups)
  - [Step 13 — Web Tier Instance](#step-13--web-tier-instance)
  - [Step 14 — Frontend & NGINX](#step-14--frontend--nginx)
  - [Step 15 — Public ALB](#step-15--public-alb)
  - [Step 16 — Auto Scaling](#step-16--auto-scaling)
  - [Step 17 — DNS & SSL](#step-17--route-53--ssl-certificate)
  - [Step 18 — WAF & Logging](#step-18--waf--s3-access-logs)
- [Security Architecture](#security-architecture)
- [High Availability](#high-availability)
- [Troubleshooting](#troubleshooting)
- [Quick Reference](#quick-reference)

---

## Project Overview

**WellNest** is a mental health and wellness platform built with a **microservices architecture** and deployed on AWS following industry-standard cloud engineering best practices. The platform provides users with mental health assessments, therapist discovery, and personalized wellness tracking.

This deployment demonstrates:

- ✅ **3-Tier Architecture** — Presentation, Application, and Database tiers are fully isolated
- ✅ **Microservices** — 3 independent backend services communicating via internal APIs
- ✅ **High Availability** — Multi-AZ deployment with Auto Scaling Groups
- ✅ **Defense in Depth** — 6-layer security group chaining with zero-trust principles
- ✅ **Enterprise Security** — AWS WAF protecting against OWASP Top 10 vulnerabilities
- ✅ **Observability** — ALB access logs persisted to Amazon S3
- ✅ **Custom Domain + HTTPS** — Route 53 DNS with ACM SSL/TLS certificate
- ✅ **Path-Based Routing** — Internal ALB intelligently routing traffic to correct microservice

> **Live URL:** [https://wellnest-project.online](https://wellnest-project.online)

---

## Architecture

<div align="center">

[![Architecture Diagram](https://i.ibb.co/ymjNX56j/architecture.png)](https://ibb.co/ymjNX56j)

*Figure 1 — WellNest AWS 3-Tier Architecture*

</div>

### Architecture Flow

```
                            Internet
                               │
                    ┌──────────▼──────────┐
                    │    AWS WAF          │  (OWASP Top 10 protection)
                    └──────────┬──────────┘
                               │
                    ┌──────────▼──────────┐
                    │   Public ALB        │  (internet-facing, HTTP:80 / HTTPS:443)
                    │  wellnest-project   │  (Route53 + ACM Certificate)
                    └──────┬──────────────┘
                           │
          ┌────────────────┴────────────────┐
          ▼                                 ▼
┌──────────────────┐              ┌──────────────────┐
│  Web Instance    │              │  Web Instance    │
│  NGINX + React   │              │  NGINX + React   │
│  web-public-1a   │              │  web-public-1b   │
└────────┬─────────┘              └────────┬─────────┘
         │  /api/* forwarded               │  /api/* forwarded
         └────────────┬────────────────────┘
                      ▼
          ┌───────────────────────┐
          │    Internal ALB       │  (path-based routing, HTTP:80)
          │  (private subnets)    │
          └──────┬────────┬───────┘
                 │        │        │
           /api/auth  /api/assess  /api/therapist
                 ▼        ▼        ▼
           Port 3001  Port 3002  Port 3003
                 │        │        │
                 └────────┼────────┘
                          │  (same EC2 instances, PM2 managed)
              ┌───────────┴───────────┐
              ▼                       ▼
   ┌──────────────────┐   ┌──────────────────┐
   │  App Instance    │   │  App Instance    │
   │  PM2: 3 services │   │  PM2: 3 services │
   │  app-private-1a  │   │  app-private-1b  │
   └────────┬─────────┘   └────────┬─────────┘
            │                      │
            └──────────┬───────────┘
                       ▼  port 27017
              ┌─────────────────┐
              │   MongoDB EC2   │
              │  db-private-1a  │
              │  (auth enabled) │
              └─────────────────┘

  SSH:  Laptop → Bastion Host (public) → All Private Instances
  Logs: Public ALB → S3 Bucket (access logs, audit trail)
```

---

## Features

### Application Features
| Feature | Description |
|---------|-------------|
| 🔐 **Authentication** | JWT-based user registration, login, and session management |
| 🧠 **Mental Health Assessments** | Structured questionnaires with scored results |
| 🩺 **Therapist Directory** | Browse, filter, and connect with licensed therapists |
| 📊 **Wellness Dashboard** | Personalized progress tracking and history |

### Infrastructure Features
| Feature | Technology |
|---------|------------|
| 🌐 **Custom Domain + HTTPS** | Route 53 + ACM SSL Certificate |
| 🛡️ **Web Application Firewall** | AWS WAF with AWS Managed Rule Groups |
| ⚖️ **Load Balancing** | Public ALB (internet-facing) + Internal ALB (path-based routing) |
| 📈 **Auto Scaling** | ASGs across 2 Availability Zones (min 2, max 4 instances) |
| 📦 **Access Logging** | ALB logs → Amazon S3 (audit trail + compliance) |
| 🔒 **Network Isolation** | 3-tier subnet design with security group chaining |
| 🚪 **Secure SSH Access** | Bastion Host pattern for private instance access |

---

## Service Map

| Service | Port | Route Prefix | Health Endpoint | Dependencies |
|---------|------|-------------|-----------------|--------------|
| **auth-service** | `3001` | `/api/auth` | `GET /health` | None |
| **assessment-service** | `3002` | `/api/assessment` | `GET /health` | → auth-service:3001 |
| **therapist-service** | `3003` | `/api/therapist` | `GET /health` | → auth-service:3001, assessment-service:3002 |
| **frontend (NGINX)** | `80` / `443` | `/` | `/health` | All services via Internal ALB |

---

## Infrastructure Components

### Network Layer

| Component | Value |
|-----------|-------|
| **VPC** | `WellNest-VPC` — `10.0.0.0/16` |
| **Internet Gateway** | `WellNest-IGW` |
| **NAT Gateway** | `WellNest-NAT` — Elastic IP in `web-public-1a` |
| **Availability Zones** | `ap-south-1a`, `ap-south-1b` (Mumbai) |

### Subnet Design

| Subnet Name | Type | AZ | CIDR | Purpose |
|-------------|------|----|------|---------|
| `web-public-1a` | Public | ap-south-1a | `10.0.1.0/24` | Web instances, Public ALB |
| `web-public-1b` | Public | ap-south-1b | `10.0.2.0/24` | Web instances, Public ALB |
| `app-private-1a` | Private | ap-south-1a | `10.0.3.0/24` | App instances, Internal ALB |
| `app-private-1b` | Private | ap-south-1b | `10.0.4.0/24` | App instances, Internal ALB |
| `db-private-1a` | Private | ap-south-1a | `10.0.5.0/24` | MongoDB EC2 |
| `db-private-1b` | Private | ap-south-1b | `10.0.6.0/24` | Reserved for DB replica |

### Security Group Chain

```
Internet → Public-ALB-SG → Web-SG → Internal-ALB-SG → App-SG → Mongo-SG
```

Each layer **only accepts traffic from the layer directly above it** — zero-trust, least-privilege security.

| Security Group | Inbound From | Ports |
|----------------|-------------|-------|
| `Public-ALB-SG` | Internet (`0.0.0.0/0`) | 80, 443 |
| `Web-SG` | `Public-ALB-SG`, `Bastion-SG` | 80, 22 |
| `Internal-ALB-SG` | `Web-SG` | 80 |
| `App-SG` | `Internal-ALB-SG`, `Bastion-SG` | 3001, 3002, 3003, 22 |
| `Mongo-SG` | `App-SG`, `Bastion-SG` | 27017, 22 |
| `Bastion-SG` | Your IP / `0.0.0.0/0` | 22 |

---

## Deployment Guide

> **Prerequisites:** AWS Account, key pair (`.pem`), and your WellNest code repository on GitHub.

---

### Step 1 — Create VPC

**AWS Console → VPC → Your VPCs → Create VPC**

| Setting | Value |
|---------|-------|
| Name tag | `WellNest-VPC` |
| IPv4 CIDR | `10.0.0.0/16` |
| Tenancy | Default |

---

### Step 2 — Internet Gateway

**VPC → Internet Gateways → Create internet gateway**

| Setting | Value |
|---------|-------|
| Name tag | `WellNest-IGW` |

After creation → **Actions → Attach to VPC → WellNest-VPC**

---

### Step 3 — Subnets

**VPC → Subnets → Create subnet → VPC: `WellNest-VPC`**

Create all 6 subnets:

#### Public Subnets

| Name | AZ | CIDR |
|------|-----|------|
| `web-public-1a` | `ap-south-1a` | `10.0.1.0/24` |
| `web-public-1b` | `ap-south-1b` | `10.0.2.0/24` |

> ⚠️ **After creating each public subnet:** Select it → Actions → Edit subnet settings → ✅ Enable auto-assign public IPv4 address

#### App Private Subnets

| Name | AZ | CIDR |
|------|-----|------|
| `app-private-1a` | `ap-south-1a` | `10.0.3.0/24` |
| `app-private-1b` | `ap-south-1b` | `10.0.4.0/24` |

#### DB Private Subnets

| Name | AZ | CIDR |
|------|-----|------|
| `db-private-1a` | `ap-south-1a` | `10.0.5.0/24` |
| `db-private-1b` | `ap-south-1b` | `10.0.6.0/24` |

---

### Step 4 — NAT Gateway

**VPC → NAT Gateways → Create NAT gateway**

| Setting | Value |
|---------|-------|
| Name | `WellNest-NAT` |
| Subnet | `web-public-1a` ⚠️ MUST be public |
| Connectivity type | Public |
| Elastic IP | Click **Allocate Elastic IP** |

> ⏳ Wait 1–2 minutes for status: **Available** before continuing.

---

### Step 5 — Route Tables

**VPC → Route Tables → Create route table**

#### Public Route Table

| Setting | Value |
|---------|-------|
| Name | `WellNest-Public-RT` |
| VPC | `WellNest-VPC` |

**Routes:**

| Destination | Target |
|-------------|--------|
| `10.0.0.0/16` | local |
| `0.0.0.0/0` | `WellNest-IGW` |

**Subnet associations:** `web-public-1a`, `web-public-1b`

---

#### App Private Route Table

| Setting | Value |
|---------|-------|
| Name | `WellNest-App-RT` |
| VPC | `WellNest-VPC` |

**Routes:**

| Destination | Target |
|-------------|--------|
| `10.0.0.0/16` | local |
| `0.0.0.0/0` | `WellNest-NAT` |

**Subnet associations:** `app-private-1a`, `app-private-1b`

---

#### DB Private Route Table

| Setting | Value |
|---------|-------|
| Name | `WellNest-DB-RT` |
| VPC | `WellNest-VPC` |

**Routes:**

| Destination | Target |
|-------------|--------|
| `10.0.0.0/16` | local |
| `0.0.0.0/0` | `WellNest-NAT` |

**Subnet associations:** `db-private-1a`, `db-private-1b`

---

### Step 6 — Security Groups

**EC2 → Security Groups → Create security group → VPC: `WellNest-VPC`**

> ⚠️ Create in this exact order — some reference others as sources.

#### `Bastion-SG`

| Rule | Protocol | Port | Source |
|------|----------|------|--------|
| Inbound | SSH | 22 | `0.0.0.0/0` |

#### `Public-ALB-SG`

| Rule | Protocol | Port | Source |
|------|----------|------|--------|
| Inbound | HTTP | 80 | `0.0.0.0/0` |
| Inbound | HTTPS | 443 | `0.0.0.0/0` |

#### `Web-SG`

| Rule | Protocol | Port | Source |
|------|----------|------|--------|
| Inbound | HTTP | 80 | `Public-ALB-SG` |
| Inbound | SSH | 22 | `Bastion-SG` |

#### `Internal-ALB-SG`

| Rule | Protocol | Port | Source |
|------|----------|------|--------|
| Inbound | HTTP | 80 | `Web-SG` |

#### `App-SG`

| Rule | Protocol | Port | Source |
|------|----------|------|--------|
| Inbound | Custom TCP | 3001 | `Internal-ALB-SG` |
| Inbound | Custom TCP | 3002 | `Internal-ALB-SG` |
| Inbound | Custom TCP | 3003 | `Internal-ALB-SG` |
| Inbound | SSH | 22 | `Bastion-SG` |

#### `Mongo-SG`

| Rule | Protocol | Port | Source |
|------|----------|------|--------|
| Inbound | Custom TCP | 27017 | `App-SG` |
| Inbound | SSH | 22 | `Bastion-SG` |

---

### Step 7 — Bastion Host

**EC2 → Launch Instances**

| Setting | Value |
|---------|-------|
| Name | `WellNest-Bastion` |
| AMI | Ubuntu Server 22.04 LTS |
| Instance type | `t2.micro` |
| Key pair | Your `.pem` key pair |
| VPC | `WellNest-VPC` |
| Subnet | `web-public-1a` |
| Auto-assign public IP | **Enabled** |
| Security group | `Bastion-SG` |

> 📝 Note the Bastion's public IP — all private instance SSH access routes through here.

---

### Step 8 — Database EC2

**EC2 → Launch Instances**

| Setting | Value |
|---------|-------|
| Name | `WellNest-MongoDB` |
| AMI | Ubuntu Server 22.04 LTS |
| Instance type | `t2.micro` |
| Key pair | Same key pair |
| Subnet | `db-private-1a` |
| Auto-assign public IP | **Disabled** |
| Security group | `Mongo-SG` |

---

### Step 9 — MongoDB Setup

#### SSH via Bastion

```bash
# Copy key to Bastion
scp -i mykey.pem mykey.pem ubuntu@<BASTION-PUBLIC-IP>:/home/ubuntu/

# SSH into Bastion
ssh -i mykey.pem ubuntu@<BASTION-PUBLIC-IP>

# SSH into MongoDB instance from Bastion
ssh -i mykey.pem ubuntu@<MONGO-PRIVATE-IP>
```

#### Install MongoDB 7.0

```bash
# Import MongoDB GPG key
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
  sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor

# Add repository
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] \
  https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
  sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Install
sudo apt update
sudo apt install -y mongodb-org

# Start and enable
sudo systemctl start mongod
sudo systemctl enable mongod
sudo systemctl status mongod
```

#### Create Admin User

```bash
mongosh
```

```javascript
use admin

db.createUser({
  user: "admin",
  pwd: "changeme",
  roles: [{ role: "root", db: "admin" }]
})

db.auth("admin", "changeme")
exit
```

#### Enable Auth & Remote Access

```bash
sudo nano /etc/mongod.conf
```

```yaml
# Network interfaces
net:
  port: 27017
  bindIp: 0.0.0.0          # ← Change from 127.0.0.1

# Security
security:
  authorization: enabled    # ← Add this section
```

```bash
sudo systemctl restart mongod

# Verify
mongosh -u admin -p changeme --authenticationDatabase admin
```

```javascript
use wellnest
db.stats()
exit
```

> 📝 **Note your MongoDB private IP** — run `hostname -I` to find it. You'll need it in the PM2 ecosystem config.

---

### Step 10 — App Tier Instance

**EC2 → Launch Instances**

| Setting | Value |
|---------|-------|
| Name | `WellNest-App-Test` |
| AMI | Ubuntu Server 22.04 LTS |
| Instance type | `t2.small` (needs RAM for 3 Node.js processes) |
| Key pair | Same key pair |
| Subnet | `app-private-1a` |
| Auto-assign public IP | **Disabled** |
| Security group | `App-SG` |

---

### Step 11 — Backend Deployment

#### SSH into App Instance

```bash
# From Bastion
ssh -i mykey.pem ubuntu@<APP-PRIVATE-IP>
```

#### Install Node.js 20 and PM2

```bash
sudo apt update && sudo apt upgrade -y

# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs git

# Verify
node --version    # v20.x
npm --version

# Install PM2 globally
sudo npm install -g pm2
```

#### Clone Repository

```bash
cd /home/ubuntu

# Public repo
git clone https://github.com/YOUR_USERNAME/WellNest.git wellnest

# Private repo (use Personal Access Token)
git clone https://YOUR_TOKEN@github.com/YOUR_USERNAME/WellNest.git wellnest
```

#### Install Dependencies

```bash
cd /home/ubuntu/wellnest/services/auth-service && npm install
cd /home/ubuntu/wellnest/services/assessment-service && npm install
cd /home/ubuntu/wellnest/services/therapist-service && npm install
```

#### Create PM2 Ecosystem File

> ⚠️ Replace `<MONGO-PRIVATE-IP>` with your actual MongoDB instance private IP.

```bash
cat > /home/ubuntu/wellnest/ecosystem.config.js << 'ECOSYSTEM'
module.exports = {
  apps: [
    {
      name: 'auth-service',
      script: 'src/index.js',
      cwd: '/home/ubuntu/wellnest/services/auth-service',
      env: {
        PORT: 3001,
        NODE_ENV: 'production',
        MONGODB_URI: 'mongodb://admin:changeme@<MONGO-PRIVATE-IP>:27017/wellnest?authSource=admin',
        JWT_SECRET: 'your-super-secret-jwt-key-change-this',
        FRONTEND_URL: '*'
      }
    },
    {
      name: 'assessment-service',
      script: 'src/index.js',
      cwd: '/home/ubuntu/wellnest/services/assessment-service',
      env: {
        PORT: 3002,
        NODE_ENV: 'production',
        MONGODB_URI: 'mongodb://admin:changeme@<MONGO-PRIVATE-IP>:27017/wellnest?authSource=admin',
        JWT_SECRET: 'your-super-secret-jwt-key-change-this',
        AUTH_SERVICE_URL: 'http://localhost:3001',
        RUN_SEED: 'true'
      }
    },
    {
      name: 'therapist-service',
      script: 'src/index.js',
      cwd: '/home/ubuntu/wellnest/services/therapist-service',
      env: {
        PORT: 3003,
        NODE_ENV: 'production',
        MONGODB_URI: 'mongodb://admin:changeme@<MONGO-PRIVATE-IP>:27017/wellnest?authSource=admin',
        JWT_SECRET: 'your-super-secret-jwt-key-change-this',
        AUTH_SERVICE_URL: 'http://localhost:3001',
        ASSESSMENT_SERVICE_URL: 'http://localhost:3002'
      }
    }
  ]
};
ECOSYSTEM

# Edit and replace MONGO-PRIVATE-IP
nano /home/ubuntu/wellnest/ecosystem.config.js
```

#### Start Services with PM2

```bash
cd /home/ubuntu/wellnest

# Start in order (auth first — others depend on it)
pm2 start ecosystem.config.js --only auth-service
sleep 5

pm2 start ecosystem.config.js --only assessment-service
sleep 5

pm2 start ecosystem.config.js --only therapist-service
sleep 3

# Verify all services running
pm2 status

# Check logs for errors
pm2 logs --lines 20

# Health check all 3 services
curl http://localhost:3001/health
curl http://localhost:3002/health
curl http://localhost:3003/health

# Persist PM2 across reboots
pm2 save
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u ubuntu --hp /home/ubuntu
```

**Expected health check responses:**
```json
{"status":"ok","service":"auth-service","timestamp":"..."}
{"status":"ok","service":"assessment-service","timestamp":"..."}
{"status":"ok","service":"therapist-service","timestamp":"..."}
```

---

### Step 12 — Internal ALB & Target Groups

#### Create Target Group 1 — `wellnest-auth-tg`

**EC2 → Target Groups → Create target group**

| Setting | Value |
|---------|-------|
| Target type | Instance |
| Name | `wellnest-auth-tg` |
| Protocol | HTTP |
| Port | `3001` |
| VPC | `WellNest-VPC` |
| Health check path | `/health` |
| Health check port | `3001` |
| Healthy threshold | 2 |
| Interval | 30s |

Register target: `WellNest-App-Test` → Port **3001**

#### Create Target Group 2 — `wellnest-assessment-tg`

Same settings, Port: **3002**, Health check port: **3002**

Register target: `WellNest-App-Test` → Port **3002**

#### Create Target Group 3 — `wellnest-therapist-tg`

Same settings, Port: **3003**, Health check port: **3003**

Register target: `WellNest-App-Test` → Port **3003**

> ⏳ Wait for all 3 target groups to show **Healthy** status before proceeding.

---

#### Create Internal ALB

**EC2 → Load Balancers → Create → Application Load Balancer**

| Setting | Value |
|---------|-------|
| Name | `WellNest-Internal-ALB` |
| Scheme | **Internal** ⚠️ NOT internet-facing |
| IP address type | IPv4 |
| VPC | `WellNest-VPC` |
| Subnets | `app-private-1a` ✅, `app-private-1b` ✅ |
| Security group | `Internal-ALB-SG` |
| Listener | HTTP : 80 → Default: Fixed 404 |

#### Configure Path-Based Routing Rules

Go to **Listeners tab → HTTP:80 → Manage rules → Add rule**

| Rule Name | Condition | Action |
|-----------|-----------|--------|
| `auth-routing` | Path is `/api/auth/*` | Forward → `wellnest-auth-tg` |
| `assessment-routing` | Path is `/api/assessment/*` | Forward → `wellnest-assessment-tg` |
| `therapist-routing` | Path is `/api/therapist/*` | Forward → `wellnest-therapist-tg` |

> 📝 **Note the Internal ALB DNS name** — you'll need it for the NGINX configuration next.

---

### Step 13 — Web Tier Instance

**EC2 → Launch Instances**

| Setting | Value |
|---------|-------|
| Name | `WellNest-Web-Test` |
| AMI | Ubuntu Server 22.04 LTS |
| Instance type | `t2.micro` |
| Key pair | Same key pair |
| Subnet | `web-public-1a` |
| Auto-assign public IP | **Enabled** |
| Security group | `Web-SG` |

---

### Step 14 — Frontend & NGINX

#### SSH into Web Instance

```bash
# From Bastion
ssh -i mykey.pem ubuntu@<WEB-PRIVATE-IP>
```

#### Install Dependencies

```bash
sudo apt update && sudo apt upgrade -y

curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs nginx git

node --version
nginx -v
```

#### Build Frontend

```bash
cd /home/ubuntu
git clone https://github.com/YOUR_USERNAME/WellNest.git wellnest

cd wellnest/services/frontend
npm install
npm run build

# Verify build output
ls -la dist/
```

#### Configure NGINX

> ⚠️ Replace `<INTERNAL-ALB-DNS>` with your actual Internal ALB DNS name.

```bash
sudo nano /etc/nginx/sites-available/default
```

Replace the entire file content:

```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /home/ubuntu/wellnest/services/frontend/dist;
    index index.html;

    # Health check for Public ALB
    location /health {
        default_type application/json;
        return 200 '{"status":"ok","service":"web-tier"}';
    }

    # Proxy /api/auth/ → Internal ALB → auth-service
    location /api/auth/ {
        proxy_pass http://<INTERNAL-ALB-DNS>/api/auth/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 30;
        proxy_read_timeout 60;
    }

    # Proxy /api/assessment/ → Internal ALB → assessment-service
    location /api/assessment/ {
        proxy_pass http://<INTERNAL-ALB-DNS>/api/assessment/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 30;
        proxy_read_timeout 60;
    }

    # Proxy /api/therapist/ → Internal ALB → therapist-service
    location /api/therapist/ {
        proxy_pass http://<INTERNAL-ALB-DNS>/api/therapist/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 30;
        proxy_read_timeout 60;
    }

    # React SPA — catch-all for client-side routing
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Static asset caching
    location ~* \.(js|css|png|jpg|ico|woff2|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Gzip compression
    gzip on;
    gzip_types text/plain application/javascript text/css application/json;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";
}
```

```bash
# Test NGINX configuration
sudo nginx -t

# Restart and enable
sudo systemctl restart nginx
sudo systemctl enable nginx

# Verify NGINX health endpoint
curl http://localhost/health

# Test API proxy through to backend
curl http://localhost/api/auth/health
```

---

### Step 15 — Public ALB

#### Create Web Target Group

**EC2 → Target Groups → Create target group**

| Setting | Value |
|---------|-------|
| Name | `wellnest-web-tg` |
| Target type | Instance |
| Protocol / Port | HTTP / 80 |
| VPC | `WellNest-VPC` |
| Health check path | `/health` |
| Healthy threshold | 2 |

Register target: `WellNest-Web-Test` → Port **80**

#### Create Public ALB

**EC2 → Load Balancers → Create → Application Load Balancer**

| Setting | Value |
|---------|-------|
| Name | `WellNest-Public-ALB` |
| Scheme | **Internet-facing** |
| Subnets | `web-public-1a` ✅, `web-public-1b` ✅ |
| Security group | `Public-ALB-SG` |

**Listener:**

| Protocol | Port | Action |
|----------|------|--------|
| HTTP | 80 | Forward → `wellnest-web-tg` |
| HTTPS | 443 | Forward → `wellnest-web-tg` (after ACM cert) |

> ✅ Once the ALB is **Active**, open `http://<PUBLIC-ALB-DNS>` in your browser.

---

### Step 16 — Auto Scaling

#### Create AMI — App Tier

**EC2 → Instances → Select `WellNest-App-Test` → Actions → Image and templates → Create image**

| Setting | Value |
|---------|-------|
| Image name | `WellNest-App-AMI` |
| Description | `App tier — Node.js 20, PM2, 3 backend microservices` |
| No reboot | ✅ Enabled |

#### Create AMI — Web Tier

**EC2 → Instances → Select `WellNest-Web-Test` → Actions → Image and templates → Create image**

| Setting | Value |
|---------|-------|
| Image name | `WellNest-Web-AMI` |
| Description | `Web tier — NGINX, React Vite frontend build` |
| No reboot | ✅ Enabled |

> ⏳ Wait for both AMIs to show status: **Available**

#### Create Launch Template — App Tier

**EC2 → Launch Templates → Create launch template**

| Setting | Value |
|---------|-------|
| Name | `WellNest-App-LT` |
| AMI | `WellNest-App-AMI` |
| Instance type | `t2.small` |
| Key pair | Your key pair |
| Security group | `App-SG` |

#### Create Launch Template — Web Tier

| Setting | Value |
|---------|-------|
| Name | `WellNest-Web-LT` |
| AMI | `WellNest-Web-AMI` |
| Instance type | `t2.micro` |
| Key pair | Your key pair |
| Security group | `Web-SG` |

#### Create Auto Scaling Group — App Tier

**EC2 → Auto Scaling groups → Create**

| Setting | Value |
|---------|-------|
| Name | `WellNest-App-ASG` |
| Launch template | `WellNest-App-LT` |
| VPC | `WellNest-VPC` |
| Subnets | `app-private-1a`, `app-private-1b` |
| Load balancing | Attach to existing target groups |
| Target groups | `wellnest-auth-tg`, `wellnest-assessment-tg`, `wellnest-therapist-tg` |
| Health check type | ELB |
| Desired capacity | 2 |
| Minimum capacity | 2 |
| Maximum capacity | 4 |
| Scaling policy | Target tracking — Average CPU > 70% |

#### Create Auto Scaling Group — Web Tier

| Setting | Value |
|---------|-------|
| Name | `WellNest-Web-ASG` |
| Launch template | `WellNest-Web-LT` |
| VPC | `WellNest-VPC` |
| Subnets | `web-public-1a`, `web-public-1b` |
| Load balancing | Attach to `wellnest-web-tg` |
| Health check type | ELB |
| Desired / Min / Max | 2 / 2 / 4 |

#### Clean Up Test Instances

Once ASG instances are **Healthy** in target groups:

1. Deregister `WellNest-App-Test` and `WellNest-Web-Test` from all target groups
2. Terminate both test instances — ASGs are now managing the fleet

---

### Step 17 — Route 53 & SSL Certificate

#### Request ACM Certificate

**AWS Console → Certificate Manager → Request certificate**

| Setting | Value |
|---------|-------|
| Certificate type | Public |
| Domain name | `wellnest-project.online` |
| Additional domain | `*.wellnest-project.online` |
| Validation method | DNS validation |

Click **Request** → Click into the certificate → **Create DNS records in Route 53** (auto-creates the CNAME validation records).

> ⏳ Wait for status: **Issued** (usually 1–3 minutes when using Route 53).

#### Configure Route 53

**Route 53 → Hosted zones → `wellnest-project.online` → Create record**

| Setting | Value |
|---------|-------|
| Record name | *(leave blank for apex domain)* |
| Record type | `A` |
| Alias | **Yes** |
| Route traffic to | **Alias to Application and Classic Load Balancer** |
| Region | `ap-south-1` |
| Load balancer | `WellNest-Public-ALB` |

#### Add HTTPS Listener to Public ALB

**EC2 → Load Balancers → WellNest-Public-ALB → Listeners → Add listener**

| Setting | Value |
|---------|-------|
| Protocol | HTTPS |
| Port | 443 |
| Default action | Forward to `wellnest-web-tg` |
| SSL certificate | Select `wellnest-project.online` from ACM |

**Optional — Redirect HTTP to HTTPS:**

Edit the HTTP:80 listener → Change action to **Redirect → HTTPS:443**

---

### Step 18 — WAF & S3 Access Logs

#### AWS WAF Setup

**AWS Console → WAF & Shield → Create web ACL**

| Setting | Value |
|---------|-------|
| Name | `WellNest-WAF` |
| Resource type | Regional resources (ALB) |
| Region | `ap-south-1` |
| Associated resource | `WellNest-Public-ALB` |

**Add Managed Rule Groups → AWS managed rule groups:**

| Rule Group | Purpose |
|------------|---------|
| ✅ Core rule set | OWASP Top 10 protection |
| ✅ SQL database | SQL injection protection |
| ✅ Known bad inputs | Malformed requests, log4j, etc. |

Set default action: **Allow**

Click **Create web ACL**

---

#### S3 Access Logging Setup

##### Create S3 Bucket

**S3 → Create bucket**

| Setting | Value |
|---------|-------|
| Bucket name | `wellnest-alb-access-logs-<yourname>` (globally unique) |
| Region | `ap-south-1` |

##### Add Bucket Policy

**S3 → Your bucket → Permissions tab → Bucket policy → Edit**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::718504428378:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::YOUR_BUCKET_NAME/AWSLogs/YOUR_AWS_ACCOUNT_ID/*"
    }
  ]
}
```

> 📝 `718504428378` is the official AWS ELB service account ID for `ap-south-1` (Mumbai). Do not change this number.

##### Enable ALB Access Logging

**EC2 → Load Balancers → WellNest-Public-ALB → Attributes tab → Edit**

- ✅ Enable **Access logs**
- S3 URI: Browse and select your bucket

> ⏳ Generate traffic by visiting the site, then check your S3 bucket in 5–10 minutes for `.log.gz` files.

---

## Security Architecture

### Defense in Depth

The architecture implements **5 layers of security**:

```
Layer 1 — AWS WAF
  └─ Blocks OWASP Top 10, SQLi, known bad actors before VPC entry

Layer 2 — Public ALB Security Group
  └─ Only accepts HTTP/HTTPS from internet; blocks all other ports

Layer 3 — Web Tier Security Group
  └─ Only accepts port 80 from Public-ALB-SG; SSH only from Bastion-SG

Layer 4 — App Tier Security Group
  └─ Only accepts 3001/3002/3003 from Internal-ALB-SG; SSH only from Bastion-SG

Layer 5 — Database Security Group
  └─ Only accepts 27017 from App-SG; SSH only from Bastion-SG
       ↳ MongoDB authentication also enabled (username/password)
```

### Network Isolation

- **Database has NO internet access** — DB route table's NAT is outbound-only; no inbound path exists from internet to database subnet
- **App instances have NO public IPs** — unreachable from internet, only via Internal ALB
- **Bastion pattern** — single controlled SSH entry point, auditable
- **MongoDB authentication enabled** — database-level access control on top of network controls

---

## High Availability

### Multi-AZ Distribution

```
Availability Zone A (ap-south-1a)    Availability Zone B (ap-south-1b)
─────────────────────────────────    ─────────────────────────────────
  web-public-1a (NGINX + React)        web-public-1b (NGINX + React)
  app-private-1a (PM2 services)        app-private-1b (PM2 services)
  db-private-1a (MongoDB)              db-private-1b (Reserved)
```

### Fault Tolerance

| Failure Scenario | System Behaviour |
|-----------------|-----------------|
| Single web instance fails | ASG replaces it; ALB routes to healthy instance in other AZ |
| Single app instance fails | ASG replaces it; Internal ALB routes to healthy instance |
| AZ-A goes down entirely | Both ALBs automatically route 100% traffic to AZ-B instances |
| CPU > 70% sustained | ASG scales out — adds up to 2 more instances per tier |

### Auto Scaling Configuration

| Group | Desired | Min | Max | Scale Trigger |
|-------|---------|-----|-----|---------------|
| `WellNest-App-ASG` | 2 | 2 | 4 | CPU > 70% |
| `WellNest-Web-ASG` | 2 | 2 | 4 | CPU > 70% |

---

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| `npm install` hangs on private EC2 | NAT Gateway not configured | Verify route table `0.0.0.0/0 → WellNest-NAT` for private subnets |
| MongoDB connection refused | `bindIp` not set to `0.0.0.0` or wrong SG | Check `/etc/mongod.conf`, verify `Mongo-SG` allows 27017 from `App-SG` |
| Internal ALB targets Unhealthy | App-SG blocking ALB | Verify `App-SG` allows ports 3001/3002/3003 from `Internal-ALB-SG` |
| NGINX 502 Bad Gateway | Wrong Internal ALB DNS in NGINX config | Check `proxy_pass` URLs, verify backend services are running |
| Frontend loads, API calls fail | NGINX proxy_pass misconfigured | Check NGINX error log: `sudo tail -f /var/log/nginx/error.log` |
| Cannot SSH to private instance | Not going through Bastion | SSH into Bastion first, then hop to private IP |
| ASG instances not joining target group | Wrong SG or subnet in launch template | Verify launch template references correct `App-SG` / `Web-SG` |
| PM2 services not running after reboot | PM2 startup not configured | Run `pm2 save` and `sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u ubuntu --hp /home/ubuntu` |
| ACM certificate stuck Pending | DNS validation records missing | In ACM console, click "Create records in Route 53" |

---

## Final Verification Checklist

```
Network Layer
  ☐ VPC created — 10.0.0.0/16
  ☐ 6 subnets created (2 public, 2 app-private, 2 db-private)
  ☐ IGW attached to VPC
  ☐ NAT Gateway in public subnet with Elastic IP
  ☐ 3 Route Tables configured with correct targets
  ☐ 6 Security Groups with proper chaining

Compute & Data Layer
  ☐ Bastion Host accessible via SSH
  ☐ MongoDB running with auth enabled (port 27017)
  ☐ 3 backend services running via PM2 (ports 3001, 3002, 3003)
  ☐ All 3 /health endpoints returning OK
  ☐ NGINX serving React frontend + proxying /api/* correctly

Load Balancing
  ☐ Internal ALB with 3 path-based routing rules (Healthy targets)
  ☐ Public ALB internet-facing and Active
  ☐ Application accessible at http://<PUBLIC-ALB-DNS>

Auto Scaling
  ☐ WellNest-App-AMI and WellNest-Web-AMI created
  ☐ Launch Templates configured
  ☐ ASGs running — 2 instances per tier, spread across AZs
  ☐ Test instances deregistered and terminated

Security & Extras
  ☐ Route 53 A record (Alias) pointing to Public ALB
  ☐ ACM Certificate issued for wellnest-project.online
  ☐ HTTPS listener on Public ALB with ACM cert
  ☐ AWS WAF attached to Public ALB (3 managed rule groups)
  ☐ S3 bucket created with correct bucket policy
  ☐ ALB access logs enabled and writing to S3

Final Checks
  ☐ https://wellnest-project.online loads correctly
  ☐ User registration works
  ☐ User login works
  ☐ Dashboard loads
  ☐ Assessments work
  ☐ Therapist directory loads
```

---

## Quick Reference

| Item | Value |
|------|-------|
| **Live URL** | `https://wellnest-project.online` |
| **VPC CIDR** | `10.0.0.0/16` |
| **Region** | `ap-south-1` (Mumbai) |
| **auth-service port** | `3001` |
| **assessment-service port** | `3002` |
| **therapist-service port** | `3003` |
| **MongoDB port** | `27017` |
| **NGINX port** | `80` |
| **MongoDB URI format** | `mongodb://admin:changeme@<DB-IP>:27017/wellnest?authSource=admin` |
| **Frontend build output** | `dist/` (Vite) |
| **PM2 config path** | `/home/ubuntu/wellnest/ecosystem.config.js` |
| **NGINX config path** | `/etc/nginx/sites-available/default` |
| **ALB ELB account (Mumbai)** | `718504428378` |

---

## Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **DNS** | Amazon Route 53 | Custom domain routing |
| **SSL/TLS** | AWS ACM | HTTPS certificate |
| **WAF** | AWS WAF | OWASP Top 10 protection |
| **CDN/LB** | AWS ALB (x2) | Public + Internal load balancing |
| **Web Tier** | NGINX + React (Vite) | Frontend serving + API reverse proxy |
| **App Tier** | Node.js 20 + PM2 | 3 microservices process management |
| **Database** | MongoDB 7.0 | Document storage |
| **Compute** | AWS EC2 | Virtual machines |
| **Scaling** | AWS Auto Scaling Groups | Automatic horizontal scaling |
| **Networking** | VPC, Subnets, SGs, NAT GW | Network isolation |
| **Logging** | Amazon S3 | ALB access log storage |
| **SSH Access** | Bastion Host | Secure private instance access |

---

<div align="center">

**Built with ❤️ on AWS | WellNest Mental Health Platform**

[![AWS](https://img.shields.io/badge/Deployed%20on-AWS-FF9900?style=for-the-badge&logo=amazon-aws)](https://aws.amazon.com)
[![Architecture](https://img.shields.io/badge/Pattern-3--Tier%20Microservices-blue?style=for-the-badge)]()
[![HA](https://img.shields.io/badge/High%20Availability-Multi--AZ-green?style=for-the-badge)]()

</div>