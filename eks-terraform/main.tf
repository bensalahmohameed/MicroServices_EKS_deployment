resource "aws_vpc" "main" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  enable_dns_support   = true
  enable_dns_hostnames = true


  tags = {
    Name = "my-eks-vpc-stack-VPC"
  }
}

resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.main.id
  availability_zone = "eu-central-1a"
  cidr_block = "192.168.0.0/18"
  map_public_ip_on_launch = true

  tags = {
    Name = "my-eks-vpc-stack-PublicSubnet01"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.128.0/18"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "my-eks-vpc-stack-PrivateSubnet01"
    "kubernetes.io/role/internal-elb" = "1"
  }
}
resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.64.0/18"
  availability_zone = "eu-central-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "my-eks-vpc-stack-PublicSubnet02"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.192.0/18"
  availability_zone = "eu-central-1b"


  tags = {
    Name = "my-eks-vpc-stack-PrivateSubnet02"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_eip" "eip1" {
  domain   = "vpc"
}

resource "aws_eip" "eip2" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "nat1" {
  allocation_id                  = aws_eip.eip1.id
  subnet_id                      = aws_subnet.private1.id

  tags= {
    Name = "my-eks-vpc-stack-NatGatewayAZ1"
  }
    depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat2" {
  allocation_id                  = aws_eip.eip2.id
  subnet_id                      = aws_subnet.private2.id

  tags = {
    Name = "my-eks-vpc-stack-NatGatewayAZ2"
  }
    depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private-rtb-1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat1.id
  }

  tags = {
    Name = "Private Subnet AZ1"
  }
}

resource "aws_route_table" "private-rtb-2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat2.id
  }

  tags = {
    Name = "Private Subnet AZ2"
  }
}

resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_route_table_association" "rt-public1" {
    subnet_id = aws_subnet.public1.id
    route_table_id = aws_route_table.public-rtb.id
}

resource "aws_route_table_association" "rt-public2" {
    subnet_id = aws_subnet.public2.id
    route_table_id = aws_route_table.public-rtb.id
}

resource "aws_route_table_association" "rt-private2" {
    subnet_id = aws_subnet.private2.id
    route_table_id = aws_route_table.private-rtb-2.id
}
resource "aws_route_table_association" "rt-private1" {
    subnet_id = aws_subnet.private1.id
    route_table_id = aws_route_table.private-rtb-1.id
}

resource "aws_security_group" "my-eks-vpc-stack-ControlPlaneSecurityGroup" {
  name        = "my-eks-vpc-stack-ControlPlaneSecurityGroup"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "my-eks-vpc-stack-ControlPlaneSecurityGroup"
  }
}
resource "aws_security_group" "k8s-default-nginxing" {
  name        = "k8s-default-nginxing"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "k8s-default-nginxing"
  }
}
resource "aws_security_group" "k8s-traffic-mycluster" {
  name        = "k8s-traffic-mycluster"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "k8s-traffic-mycluster"
  }
}

resource "aws_vpc_security_group_egress_rule" "k8s-traffic-mycluster" {
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 0
  ip_protocol = "All"
  to_port     = 65535
  security_group_id = aws_security_group.k8s-traffic-mycluster.id
}

resource "aws_vpc_security_group_ingress_rule" "k8s-default-nginxing" {
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "TCP"
  to_port     = 80
  security_group_id = aws_security_group.k8s-default-nginxing.id
}
resource "aws_vpc_security_group_egress_rule" "k8s-default-nginxing" {
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 0
  ip_protocol = "All"
  to_port     = 65535
  security_group_id = aws_security_group.k8s-default-nginxing.id
}

resource "aws_vpc_security_group_egress_rule" "my-eks-vpc-stack-ControlPlaneSecurityGroup" {
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 0
  ip_protocol = "All"
  to_port     = 65535
  security_group_id = aws_security_group.my-eks-vpc-stack-ControlPlaneSecurityGroup.id
}



###############################################

resource "aws_iam_role" "eks-role" {
  name = "myAmazonEKSClusterRole"

  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
  })
}

resource "aws_iam_role_policy_attachment" "eks-policy-attach" {
  role       = aws_iam_role.eks-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy" 
}


resource "aws_iam_role" "eks-worker-role" {
  name = "myAmazonEKSNodeRole"

  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
  })
}

resource "aws_iam_role_policy_attachment" "eks-worker-policy-attach-1" {
  role       = aws_iam_role.eks-worker-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy" 
}
resource "aws_iam_role_policy_attachment" "eks-worker-policy-attach-2" {
  role       = aws_iam_role.eks-worker-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly" 
}
resource "aws_iam_role_policy_attachment" "eks-worker-policy-attach-3" {
  role       = aws_iam_role.eks-worker-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy" 
}

resource "aws_eks_cluster" "my-cluster" {
  name     = "my-cluster"
  role_arn = aws_iam_role.eks-role.arn

  vpc_config {
    subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id, aws_subnet.public1.id, aws_subnet.public2.id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks-policy-attach,
  ]
}

resource "aws_eks_addon" "vpc-cni" {
  cluster_name = aws_eks_cluster.my-cluster.name
  addon_name   = "vpc-cni"
}
resource "aws_eks_addon" "eks-pod-identity-agent" {
  cluster_name = aws_eks_cluster.my-cluster.name
  addon_name   = "eks-pod-identity-agent"
}
resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.my-cluster.name
  addon_name   = "coredns"
}
resource "aws_eks_addon" "kube-proxy" {
  cluster_name = aws_eks_cluster.my-cluster.name
  addon_name   = "kube-proxy"
}

data "tls_certificate" "example" {
  url = aws_eks_cluster.my-cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "example" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.example.certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.example.url
}

resource "aws_eks_node_group" "my-ng" {
  cluster_name    = aws_eks_cluster.my-cluster.name
  node_group_name = "my-ng"
  node_role_arn   = aws_iam_role.eks-worker-role.arn
  subnet_ids      = [aws_subnet.private1.id, aws_subnet.private2.id, aws_subnet.public1.id, aws_subnet.public2.id]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks-worker-policy-attach-1,
    aws_iam_role_policy_attachment.eks-worker-policy-attach-2,
    aws_iam_role_policy_attachment.eks-worker-policy-attach-3,
  ]
}



#######################################

resource "aws_iam_policy" "elb-policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "AWSLoadBalancerControllerIAMPolicy"
  policy = file("./elb-policy.json")
}

data "aws_iam_policy_document" "example_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.example.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "${aws_iam_openid_connect_provider.example.url}:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "${aws_iam_openid_connect_provider.example.url}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "elb-role" {
  name = "AmazonEKSLoadBalancerControllerRole"
  assume_role_policy = data.aws_iam_policy_document.example_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "elb-policy-attachment" {
  role       = aws_iam_role.elb-role.name
  policy_arn = aws_iam_policy.elb-policy.arn
}

output "elb-role-arn" {
  value = aws_iam_role.elb-role.arn
}

output "vpc_id" {
  value = aws_vpc.main.id
}