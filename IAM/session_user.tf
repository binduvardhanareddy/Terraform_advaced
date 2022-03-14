provider "aws" {
  region = "us-east-2" # OHIO
}
resource "aws_iam_user" "session_user" {  # resource "resource_type" "resource_name_in_terraform_project"
  # argument to be provided to create the resource
  name = "kul-ibm"
  tags = {
    Client = "IBM"
    Description = "IBM Terraform Batch"
    From = "07/03/2022"
    Till = "11/03/2022"
  }
}
resource "aws_iam_access_key" "session_user" {
  user = aws_iam_user.session_user.name # Refer the attributes of resources created with in the project
}
resource "aws_iam_policy_attachment" "ec2" {
  name = "ec2"
  policy_arn = "arn:aws:iam::554660509057:policy/kul-ec2"
  users = [ aws_iam_user.session_user.name ]
}
resource "aws_iam_policy_attachment" "rds" {
  name = "rds"
  policy_arn = "arn:aws:iam::554660509057:policy/kul-rds"
  users = [ aws_iam_user.session_user.name ]
}
resource "aws_iam_policy_attachment" "asg" {
  name = "asg"
  policy_arn = "arn:aws:iam::554660509057:policy/kul-asg"
  users = [ aws_iam_user.session_user.name ]
}
output "access_id" {
  value = aws_iam_access_key.session_user.id
}


#### SNS to be used for Auto Scaling Group
resource "aws_sns_topic" "asg_notification" {
  name = "kul"
  display_name = "kul"
}
resource "aws_sns_topic_subscription" "asg_subscription" {
  topic_arn = aws_sns_topic.asg_notification.arn
  protocol = "email"
  endpoint = "kulbhushan.mayer@gmail.com"
}


#### Policy for Read Access on SNS Topic
resource "aws_iam_policy" "sns_read_only" {
  name        = "kul_sns_read_only"
  path        = "/"
  description = "kul_sns_read_only"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": [
          "sns:ListTagsForResource",
          "sns:ListSubscriptionsByTopic",
          "sns:GetTopicAttributes"
        ],
        "Resource": "arn:aws:sns:us-east-2:554660509057:kul"
      },
      {
        "Sid": "VisualEditor1",
        "Effect": "Allow",
        "Action": [
          "sns:ListSMSSandboxPhoneNumbers",
          "sns:ListTopics",
          "sns:GetPlatformApplicationAttributes",
          "sns:GetSubscriptionAttributes",
          "sns:ListSubscriptions",
          "sns:CheckIfPhoneNumberIsOptedOut",
          "sns:ListOriginationNumbers",
          "sns:ListPhoneNumbersOptedOut",
          "sns:ListEndpointsByPlatformApplication",
          "sns:GetEndpointAttributes",
          "sns:GetSMSSandboxAccountStatus",
          "sns:GetSMSAttributes",
          "sns:ListPlatformApplications"
        ],
        "Resource": "*"
      }
    ]
  })
}
resource "aws_iam_policy_attachment" "sns" {
  name = "sns"
  policy_arn = aws_iam_policy.sns_read_only.arn
  users = [ aws_iam_user.session_user.name ]
}

resource "aws_iam_policy_attachment" "elb" {
  name = "elb"
  policy_arn = "arn:aws:iam::554660509057:policy/kul-elb"
  users = [ aws_iam_user.session_user.name ]
}

# creating role for eks cluster, node group & cluster access
module "cluster_role"{
  source = "../modules/iam/roles"
  name = "eks_cluster_role_1"
  service = "eks"
}
module "ec2_role" {
  for_each = toset(["eks_node_group_role","eks_cluster_access_role"])
  source = "../modules/iam/roles"
  name = each.value
  service = "ec2"
}
# attaching policy with the roles
module "cluster_policy_attachment"{
  for_each = toset(["AmazonEKSClusterPolicy","AmazonEKSVPCResourceController"])
  source = "../modules/iam/attach_policy"
  role = module.cluster_role.role_name
  policy = each.value
}
module "node_group_role_policy_attachment"{
  for_each = toset(["AmazonEC2ContainerRegistryReadOnly","AmazonEKSWorkerNodePolicy","AmazonEKS_CNI_Policy"])
  source = "../modules/iam/attach_policy"
  role = module.ec2_role["eks_node_group_role"].role_name
  policy = each.value
}
resource "aws_iam_role_policy" "eks_cluster_access_role_policy" {
  name = "eks_cluster_access_role_policy"
  role = module.ec2_role["eks_cluster_access_role"].role_name
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:AccessKubernetesApi",
          "ssm:GetParameter",
          "eks:ListUpdates",
          "eks:ListFargateProfiles"
        ],
        "Resource": "*"
      }
    ]
  })
}
resource "aws_iam_instance_profile" "eks_cluster_access_role" {
  name = module.ec2_role["eks_cluster_access_role"].role_name
  role = module.ec2_role["eks_cluster_access_role"].role_name
}




