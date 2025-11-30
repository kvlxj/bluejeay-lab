# Bluejeay Lab

## Project Overview

This is an infrastructure-as-code project for provisioning AWS infrastructure using OpenTofu/Terraform. The project sets up a complete Kubernetes environment on AWS with networking, security, and autoscaling capabilities.

## Technologies & Tools

- **IaC Tool**: OpenTofu/Terraform
- **Cloud Provider**: AWS
- **Container Orchestration**: Amazon EKS (Elastic Kubernetes Service)
- **Networking**: AWS VPC with public/private/intra subnets
- **Node OS**: Bottlerocket (AWS's purpose-built container OS)
- **CNI**: Cilium (indicated by node taints)
- **Autoscaling**: Karpenter
- **Secure Access**: Tailscale integration
- **Cost Optimization**: SPOT instances

## Project Structure

```
tofu/
├── vpc/              # VPC infrastructure
│   ├── vpc.tf        # VPC module configuration
│   ├── variables.tf  # Variable definitions
│   ├── locals.tf     # Local values
│   ├── providers.tf  # Provider configuration
│   ├── backend.tf    # Remote state backend
│   └── versions.tf   # Version constraints
└── eks/              # EKS cluster infrastructure
    ├── eks.tf        # EKS module configuration
    └── variables.tf  # Variable definitions
```

## Infrastructure Components

### VPC (Virtual Private Cloud)
- **Name**: bluejeay-lab-vpc
- **Subnets**:
  - Private subnets: For EKS worker nodes (tagged for internal load balancers)
  - Public subnets: For NAT gateways and external load balancers
  - Intra subnets: For EKS control plane
- **Features**:
  - Single NAT gateway (cost optimization)
  - VPC Flow Logs enabled with CloudWatch
  - DNS hostnames enabled
  - Kubernetes-aware subnet tagging

### EKS Cluster
- **Private API endpoint** (not publicly accessible)
- **Node Groups**:
  - Managed node group "main" for bootstrapping Karpenter
  - Bottlerocket AMI (v1.49.0-713f44ce)
  - SPOT instances for cost savings
  - Instance types: c7i, c6i, t3a families
  - Min: 2, Max: 3, Desired: 2 nodes
- **Add-ons**:
  - CoreDNS with autoscaling (2-4 replicas)
  - EKS Pod Identity Agent
- **Security**:
  - Tailscale security group for API server access
  - IMDSv2 required (http_tokens = required)
  - Optional SSM access for node management
- **Special Configurations**:
  - Cilium taint for proper CNI initialization
  - Karpenter discovery tags
  - API server service proxy support

## Development Guidelines

### Working with OpenTofu/Terraform

1. **State Management**: This project uses remote state backend (check `backend.tf`)
2. **Variable Files**: Use `.tfvars` files for environment-specific values
3. **Security**: Never commit sensitive values or `.pem` files (covered in `.gitignore`)

### Common Operations

```bash
# Initialize OpenTofu
tofu init

# Plan changes
tofu plan -var-file=var.tfvars

# Apply changes
tofu apply -var-file=var.tfvars

# Destroy infrastructure
tofu destroy -var-file=var.tfvars
```

### Cost Considerations

- Single NAT gateway shared across AZs
- SPOT instances for worker nodes
- Bottlerocket OS (minimal footprint)
- Autoscaling with Karpenter for efficient resource usage

### Security Best Practices

- Private EKS API endpoint (accessible via Tailscale)
- IMDSv2 enforcement on EC2 instances
- VPC Flow Logs enabled for network monitoring
- Security groups properly configured for least privilege access

## Key Configuration Points

1. **VPC CIDR**: Defined in `var.tfvars`, subnets auto-calculated
2. **Kubernetes Version**: Configurable via `kubernetes_version` variable
3. **Instance Types**: Multiple instance types defined for SPOT diversity
4. **Add-ons**: CoreDNS autoscaling and Pod Identity Agent enabled
5. **Taints**: Cilium taint ensures CNI is ready before pod scheduling

## Integration Points

- **Tailscale**: Provides secure access to private EKS API endpoint
- **Karpenter**: Looks for cluster via `karpenter.sh/discovery` tag
- **Cilium**: Node taint ensures proper initialization before workload scheduling

## Notes

- This is a lab/development environment optimized for cost
- Production deployments should consider multi-NAT gateway for HA
- Bottlerocket provides automatic security updates and smaller attack surface
- EKS managed node group is primarily for bootstrapping Karpenter; most workloads should use Karpenter-managed nodes
