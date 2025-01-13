# MicroServices_EKS_deployment

This repository contains Terraform configurations and Kubernetes manifests to provision an Amazon EKS cluster, including all necessary networking infrastructure (VPC, subnets, ...) and IAMs to securely deploy a real-time bitcoin price-tracking application.

---

## Features
- **VPC Setup**:
  - A custom VPC with public and private subnets across two availability zones.
- **EKS Cluster**:
  - Fully managed Amazon EKS cluster with worker node groups.
- **ALB Ingress**:
  - Application Load Balancer (ALB) provisioned using AWS Load Balancer Controller.
- **Secure IAM Policies**:
  - Fine-grained IAM policies for managing ALB, EKS, and worker node permissions.
- **Bitcoin Price Application**
  - Microserives based application for Bitcoin price live track.

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
git clone https://github.com/bensalahmohameed/MicroServices_EKS_deployment.git
cd MicroServices_EKS_deployment
```

### 2. Set Up AWS Credentials
Make sure your AWS CLI is configured with credentials:
```bash
aws configure
```

### 3. Initialize and Apply Terraform
Navigate to the Terraform module directory:
```bash
cd eks-terraform
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

### 4. Deploy Kubernetes Resources
Once the EKS cluster is up, configure `kubectl`:
```bash
aws eks --region eu-central-1 update-kubeconfig --name my-cluster
```

Prepare the ingress contoller:
```bash
kubectl apply -f aws-load-balancer-controller-service-account.yaml
```

```bash
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=my-cluster --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller --set region=eu-central-1 --set vpcId=XXX
```

Apply the Kubernetes manifests:
```bash
kubectl apply -f ingress.yaml
kubectl apply -f frontend.yaml
kubectl apply -f backend.yaml
```
---

## Validating Deployment
1. **Verify EKS Cluster**:
   Check the status of the EKS cluster:
   ```bash
   aws eks describe-cluster --name my-cluster
   ```

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
Make sure to delete the load balancer provisioned with the ALB manually from aws console

---


## Contact
For any questions or issues, feel free to reach out:
- **Author**: Mohamed Ben Salah
- **Email**: [benz.mohamed2000@gmail.com](benz.mohamed2000@gmail.com)
