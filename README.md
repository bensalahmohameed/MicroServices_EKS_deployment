﻿# MicroServices_EKS_deployment

This repository contains Terraform configurations and Kubernetes manifests to deploy an Amazon EKS cluster, including all necessary networking infrastructure (VPC, subnets, NAT gateways) and an ALB ingress controller for managing application traffic.

---

## Features
- **VPC Setup**:
  - A custom VPC with public and private subnets across two availability zones.
  - NAT Gateways for private subnet internet access.
- **EKS Cluster**:
  - Fully managed Amazon EKS cluster with worker node groups.
  - IAM roles configured for EKS and worker nodes.
- **ALB Ingress**:
  - Application Load Balancer (ALB) provisioned using AWS Load Balancer Controller.
  - Ingress configuration for exposing Kubernetes services.
- **Secure IAM Policies**:
  - Fine-grained IAM policies for managing ALB, EKS, and worker node permissions.

---

## Prerequisites
Ensure the following tools are installed on your local machine:
- [Terraform](https://www.terraform.io/downloads.html) (v1.3 or higher)
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- AWS account with proper permissions.

---

## Deployment Steps

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/your-repository.git
cd your-repository
```

### 2. Set Up AWS Credentials
Make sure your AWS CLI is configured with credentials:
```bash
aws configure
```

### 3. Initialize and Apply Terraform
Navigate to the Terraform module directory:
```bash
cd terraform
```

Run the following commands:
```bash
terraform init
terraform plan
terraform apply
```

This will:
1. Create the VPC with public and private subnets.
2. Set up EKS with the required IAM roles and node groups.
3. Deploy the AWS Load Balancer Controller.

### 4. Deploy Kubernetes Resources
Once the EKS cluster is up, configure `kubectl`:
```bash
aws eks --region <region> update-kubeconfig --name my-cluster
```

Apply the Kubernetes manifests:
```bash
kubectl apply -f k8s/ingress.yaml
kubectl apply -f k8s/frontend-service.yaml
kubectl apply -f k8s/frontend-deployment.yaml
```

---

## Project Structure
```plaintext
.
├── terraform/
│   ├── main.tf            # Main Terraform configurations
│   ├── variables.tf       # Input variables
│   ├── outputs.tf         # Outputs
│   └── elb-policy.json    # IAM policy for ALB Controller
├── k8s/
│   ├── ingress.yaml       # Ingress resource for ALB
│   ├── frontend-service.yaml # Kubernetes service
│   └── frontend-deployment.yaml # Kubernetes deployment
├── README.md              # Project documentation
```

---

## Configuration
### Customizing the Terraform Variables
You can modify `variables.tf` to change:
- VPC CIDR ranges
- Number of subnets
- Cluster name
- Scaling configuration for node groups

### Customizing Kubernetes Manifests
Edit the Kubernetes manifests under the `k8s/` directory to adjust:
- Deployment replicas
- Service ports
- Ingress routing rules

---

## Validating Deployment
1. **Verify EKS Cluster**:
   Check the status of the EKS cluster:
   ```bash
   aws eks describe-cluster --name my-cluster
   ```

2. **Verify ALB**:
   Log into the AWS console and confirm that an ALB is provisioned under the EC2 → Load Balancers section.

3. **Test the Application**:
   Retrieve the ALB's DNS name:
   ```bash
   kubectl describe ingress nginx-ingress
   ```
   Access the application in your browser using the DNS name.

---

## Clean-Up
To destroy all resources created by Terraform:
```bash
terraform destroy
```
Make sure to delete any Kubernetes resources manually:
```bash
kubectl delete -f k8s/
```

---

## Troubleshooting
1. **ALB Not Created**:
   - Verify the AWS Load Balancer Controller is running:
     ```bash
     kubectl get pods -n kube-system
     ```
2. **Ingress Not Accessible**:
   - Check ALB status in the AWS console.
   - Verify Ingress resource:
     ```bash
     kubectl get ingress nginx-ingress
     ```

---

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Contact
For any questions or issues, feel free to reach out:
- **Author**: Mohamed Ben Salah
- **Email**: [your-email@example.com](mailto:your-email@example.com)
