# security group
security_group_name                    = "all"
security_group_description             = "security group for all"
security_group_name_eks_cluster        = "eks_cluster"
security_group_description_eks_cluster = "security group for eks cluster"
port_80                                = 80
port_443                               = 443
port_22                                = 22
port_3000                              = 3000
port_8080                              = 8080
# port_8081                              = 8081
port_10250              = 10250
port_30007              = 30007
port_9000               = 9000
port_9090               = 9090
port_9100               = 9100
port_9443               = 9443
port_3306               = 3306
security_group_protocol = "tcp"
web_cidr                = "0.0.0.0/0"
private_ip_address      = "70.53.230.66/32"

# vpc
vpc_cidr_block                   = "10.0.0.0/16"
vpc_name                         = "vpc"
public_subnet_cidr_blocks        = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidr_blocks       = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
availability_zones               = ["us-east-1a", "us-east-1b", "us-east-1c"]
aws_subnet_public_name           = "public_subnets"
aws_subnet_public_eks_alb        = "kubernetes.io/role/elb"
aws_subnet_public_eks_alb_value  = 1
aws_subnet_private_name          = "private_subnets"
aws_subnet_private_eks_alb       = "kubernetes.io/role/internal-elb"
aws_subnet_private_eks_alb_value = 1


# Internet Gateway variables
igw_name = "igw"

# Route Table variables
rt_name = "route-table"

# Route Table Association variables
rt_association = "rt-association"

# eks
eks_cluster_netflix_name                                = "eks-netflix-cluster"
aws_eks_node_group_netflix_name                         = "eks-node-group"
aws_eks_node_group_instance_types                       = "m5.large"
aws_eks_node_group_desired_capacity                     = 1
aws_eks_node_group_min_size                             = 1
aws_eks_node_group_max_size                             = 3
aws_eks_node_group_launch_template_name_prefix          = "netflix"
aws_eks_node_group_launch_template_version              = "$Latest"
aws_eks_node_group_device_name                          = "xvda"
aws_eks_node_group_volume_size                          = 20
aws_eks_cluster_netflix_version                         = "1.29"
aws_eks_addon_netflix_addon_name                        = "vpc-cni"
aws_eks_addon_netflix_addon_version                     = "v1.16.2-eksbuild.1"
aws_eks_cluster_netflix_enabled_cluster_log_types       = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
aws_instance_eks_cluster_netflix_bastion_host_file_type = "ssh"
aws_instance_eks_cluster_netflix_bastion_host_file_user = "ec2-user"

# asg
key_pair_name                                                 = "web-ec2"
aws_launch_template_netflix_name_prefix                       = "netflix-launch-template"
aws_launch_template_netflix_image_id                          = "ami-002dee9c84261ad4a"
aws_launch_template_netflix_instance_type                     = "m5.large"
aws_launch_template_netflix_block_device_mappings_device_name = "xvdc"
aws_launch_template_netflix_block_device_mappings_volume_size = 20
aws_launch_template_netflix_create_before_destroy             = true
aws_autoscaling_group_netflix_desired_capacity                = 2
aws_autoscaling_group_netflix_max_size                        = 4
aws_autoscaling_group_netflix_min_size                        = 1
aws_autoscaling_group_netflix_launch_template_version         = "$Latest"
aws_autoscaling_group_netflix_tag_key                         = "Environment"
aws_autoscaling_group_netflix_tag_value                       = "Dev"
aws_autoscaling_group_netflix_tag_propagate_at_launch         = true
aws_launch_template_netflix_user_data                         = <<-EOT
#!/bin/bash
set -ex
sudo yum update -y

# Define the log file
LOG_FILE="/var/log/userdata.log"

# Redirect all output (stdout and stderr) to the log file
exec >> "$LOG_FILE" 2>&1

set -x
AWS_ACCESS_KEY_ID="*"
AWS_SECRET_ACCESS_KEY="*"
AWS_REGION="us-east-1"
CLUSTER_NAME="eks-netflix-cluster"
NODE_GROUP_INSTANCE_TYPE="m5.large"
KUBERNETES_VERSION="1.29"

sudo -u ec2-user /usr/bin/aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
sudo -u ec2-user /usr/bin/aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
sudo -u ec2-user /usr/bin/aws configure set  default.region $AWS_REGION
echo "AWS CLI configured with your credentials."

# clone code repo
set -x
if ! [ -x "$(command -v git)" ]; then
    echo "Installing git..."
    set -x
    sudo yum install git -y
    echo "git installed."
else
    echo "git is already installed."
fi

set -x
cd /home/ec2-user
sudo -u ec2-user /usr/bin/git clone https://github.com/N4si/DevSecOps-Project.git
cd DevSecOps-Project


if ! [ -x "$(command -v kubectl)" ]; then
    echo "Installing kubectl..."
    set -x
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/bin/
    echo "kubectl installed."
else
    echo "kubectl is already installed."
fi


set -x
sudo -u ec2-user /usr/bin/aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

set -x
curl -O https://raw.githubusercontent.com/awslabs/amazon-eks-ami/master/files/max-pods-calculator.sh
chmod +x max-pods-calculator.sh

CERTIFICATE_AUTHORITY=$(sudo -u ec2-user /usr/bin/aws eks describe-cluster --query "cluster.certificateAuthority.data" --output text --name $CLUSTER_NAME --region $AWS_REGION)

API_SERVER_ENDPOINT=$(sudo -u ec2-user /usr/bin/aws eks describe-cluster --region $AWS_REGION --name $CLUSTER_NAME --query "cluster.endpoint" --output text)

SERVICE_CIDR=$(sudo -u ec2-user /usr/bin/aws eks describe-cluster --query "cluster.kubernetesNetworkConfig.serviceIpv4Cidr" --output text --name $CLUSTER_NAME --region $AWS_REGION | sed 's/\.0\/16//')

CNI_VERSION=$(sudo -u ec2-user /usr/bin/aws eks describe-addon-versions --addon-name vpc-cni --kubernetes-version $KUBERNETES_VERSION --region $AWS_REGION | jq -r '.addons[] | select(.addonName == "vpc-cni") | .addonVersions[].addonVersion' | head -n 1 | sed 's/^v//')

MAX_PODS=$(./max-pods-calculator.sh --instance-type $NODE_GROUP_INSTANCE_TYPE --cni-version $CNI_VERSION)

set -x
/etc/eks/bootstrap.sh eks-netflix-cluster $CLUSTER_NAME \
  --b64-cluster-ca $CERTIFICATE_AUTHORITY \
  --apiserver-endpoint $API_SERVER_ENDPOINT \
  --dns-cluster-ip $SERVICE_CIDR.10 \
  --kubelet-extra-args "--max-pods=$MAX_PODS" \
  --use-max-pods false

# Install docker and run the app using a container
set -x 
sudo yum install docker -y
sudo usermod -aG docker ec2-user
sudo systemctl start docker && sudo systemctl enable docker
sudo chmod 777 /var/run/docker.sock

# Netflix will be installed using jenkins in pipeline
# sudo -u ec2-user /usr/bin/docker build --build-arg TMDB_V3_API_KEY='828c08825f468a73ab49608d4425d31c' -t netflix .
# sudo -u ec2-user /usr/bin/docker run -d --name netflix -p 30007:80 netflix:latest

# Install sonarqube on port 9000
set -x
sudo docker run -d --name sonar -p 9000:9000 sonarqube:lts-community

# Install trivy
set -x
sudo wget https://github.com/aquasecurity/trivy/releases/download/v0.20.0/trivy_0.20.0_Linux-64bit.rpm
sudo yum install -y ./trivy_0.20.0_Linux-64bit.rpm
sudo rm trivy_0.20.0_Linux-64bit.rpm

# Installation of Jenkins
# set -x
# sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
# sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
# sudo amazon-linux-extras install java-openjdk11 -y
# sudo yum install jenkins -y
# sudo systemctl enable jenkins && sudo systemctl start jenkins

# Admin password for Jenkins
# cat /var/lib/jenkins/secrets/initialAdminPassword

# Installion of Prometheus
set -x
sudo useradd --system --no-create-home --shell /bin/false prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.50.0/prometheus-2.50.0.linux-amd64.tar.gz
tar -xvf prometheus-2.50.0.linux-amd64.tar.gz
cd prometheus-2.50.0.linux-amd64/
sudo mkdir -p /data /etc/prometheus
sudo mv prometheus promtool /usr/local/bin/
sudo mv consoles/ console_libraries/ /etc/prometheus/
sudo mv prometheus.yml /etc/prometheus/prometheus.yml
sudo chown -R prometheus:prometheus /etc/prometheus/ /data/
sudo rm /home/ec2-user/DevSecOps-Project/prometheus-2.50.0.linux-amd64.tar.gz

# Prometheus service unit definition
set -x
cat <<EOF | sudo tee /etc/systemd/system/prometheus.service > /dev/null
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
User=prometheus
Group=prometheus
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/prometheus \\
    --config.file=/etc/prometheus/prometheus.yml \\
    --storage.tsdb.path=/data \\
    --web.console.templates=/etc/prometheus/consoles \\
    --web.console.libraries=/etc/prometheus/console_libraries \\
    --web.listen-address=0.0.0.0:9090 \\
    --web.enable-lifecycle

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to pick up the changes
set -x
sudo systemctl daemon-reload

# Enable and start the Prometheus service
sudo systemctl enable prometheus && sudo systemctl start prometheus

# # Installation of Node Exporter
# sudo useradd --system --no-create-home --shell /bin/false node_exporter
# wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
# tar -xvf node_exporter-1.7.0.linux-amd64.tar.gz
# sudo mv node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/
# rm -rf node_exporter*

# set -x
# cat <<EOF | sudo tee /etc/systemd/system/node_exporter.service > /dev/null
# [Unit]
# Description=Node Exporter
# Wants=network-online.target
# After=network-online.target

# StartLimitIntervalSec=500
# StartLimitBurst=5

# [Service]
# User=node_exporter
# Group=node_exporter
# Type=simple
# Restart=on-failure
# RestartSec=5s
# ExecStart=/usr/local/bin/node_exporter --collector.logind

# [Install]
# WantedBy=multi-user.target
# EOF

# # Reload systemd to pick up the changes
# set -x
# sudo systemctl daemon-reload

# # Enable and start the Node Exporter service
# sudo systemctl enable node_exporter && sudo systemctl start node_exporter

# Install Argocd
sudo -u ec2-user /usr/bin/kubectl create namespace argocd 
sudo -u ec2-user /usr/bin/kubectl apply -n argocd -f https://raw.githubusercontent.com/lightninglife/argo-cd/master/argocd.yaml

# sudo -u ec2-user /usr/bin/kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}, "metadata": {"annotations": {"service.beta.kubernetes.io/aws-load-balancer-type": "alb"}}}'

# Install Node Exporter using Helm
sudo -u ec2-user /usr/bin/curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
sudo -u ec2-user /usr/local/bin/helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
sudo -u ec2-user /usr/bin/kubectl create namespace prometheus-node-exporter
sudo -u ec2-user /usr/local/bin/helm install prometheus-node-exporter prometheus-community/prometheus-node-exporter --namespace prometheus-node-exporter

export ARGOCD_SERVER=`sudo -u ec2-user /usr/bin/kubectl get svc argocd-server -n argocd -o json | jq --raw-output '.status.loadBalancer.ingress[0].hostname'`
echo $ARGOCD_SERVER
export ARGO_PWD=`sudo -u ec2-user /usr/bin/kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`
echo $ARGO_PWD


# Edit Prometheus Yaml file
set -x
cat <<EOF | sudo tee /etc/prometheus/prometheus.yml > /dev/null
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # - job_name: 'jenkins'
  #   metrics_path: '/prometheus/'
  #   static_configs:
  #     - targets: ['localhost:8080']

  - job_name: 'netflix'
    static_configs:
      - targets: ['localhost:30007']
  
  - job_name: 'grafana'
    static_configs:
      - targets: ['localhost:3000']
  
EOF

# Reload Prometheus 
curl -X POST http://localhost:9090/-/reload

# Installation of Grafana
set -x
sudo yum install -y https://dl.grafana.com/enterprise/release/grafana-enterprise-10.3.3-1.x86_64.rpm

sudo systemctl start grafana-server && sudo systemctl enable grafana-server

# Installation of Kubergrunt
wget https://github.com/gruntwork-io/kubergrunt/releases/download/v0.14.2/kubergrunt_linux_amd64
sudo mv kubergrunt_linux_amd64 kubergrunt
sudo mv kubergrunt /usr/bin/
sudo chmod -R 777 /usr/bin/kubergrunt


EOT

#iam
aws_iam_role_eks_cluster_netflix_name                             = "netflix-cluster-role"
aws_iam_role_eks_nodegroup_role_netflix_name                      = "netflix-nodegroup-role"
data_http_lbc_iam_policy_url                                      = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"
data_http_lbc_iam_policy_request_headers_accept                   = "application/json"
aws_iam_role_policy_attachment_eks_AmazonEKSClusterPolicy         = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
aws_iam_role_policy_attachment_eks_AmazonEKSVPCResourceController = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
aws_iam_role_eks_nodegroup_role_netflix_assume_role_policy = {
  Statement = [

    {
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = ["ec2.amazonaws.com", "eks.amazonaws.com"]
      }
    }
  ]
}
aws_iam_policy_attachment_eks_worker_node_policy_name                    = "eks-worker-node-policy-attachment"
aws_iam_policy_attachment_eks_worker_node_policy_policy_arn              = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
aws_iam_policy_attachment_eks_cni_policy_name                            = "eks_cni-policy"
aws_iam_policy_attachment_eks_cni_policy_policy_arn                      = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
aws_iam_policy_attachment_eks_ec2_container_registry_readonly_name       = "eks_worker_nodes_policy"
aws_iam_policy_attachment_eks_ec2_container_registry_readonly_policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

# bastion
aws_instance_eks_cluster_netflix_bastion_host_ami                     = "ami-002dee9c84261ad4a"
aws_instance_eks_cluster_netflix_bastion_host_instance_type           = "t2.micro"
aws_instance_eks_cluster_netflix_bastion_host_tags                    = "bastion-host"
aws_instance_eks_cluster_netflix_bastion_host_provisioner_destination = "/home/ec2-user/web-ec2.pem"
aws_instance_eks_cluster_netflix_bastion_host_remote_exec_inline      = ["sudo chmod 400 /home/ec2-user/web-ec2.pem"]