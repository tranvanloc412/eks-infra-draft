data "aws_iam_policy_document" "eks-describe" {
  statement {
    effect = "Allow"
    actions = [
      "eks:Describe*",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role" "EksCodeBuildKubectlRole" {
  name = "EksCodeBuildKubectlRole"

  assume_role_policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
     {

       "Action": "sts:AssumeRole",
       "Principal": {
         "AWS": [ "arn:aws:iam::398692602192:root" ]
       },
       "Effect": "Allow",
       "Sid": ""
     }
   ]
}
 EOF
}

resource "aws_iam_role_policy" "eks-describe" {
  name   = "eks-${var.cluster_name}-eks-describe"
  role   = aws_iam_role.EksCodeBuildKubectlRole.id
  policy = data.aws_iam_policy_document.eks-describe.json
}

##########################################################################

resource "aws_cloudwatch_log_group" "this" {
  name = "eks-codebuild-logg-roup"

  tags = {
    Environment = "production"
    Application = "eks-infra"
  }
}

resource "aws_s3_bucket" "artifacts" {
  bucket = "loctran-s3-codebuild-artifacts"
  acl    = "private"
}

resource "aws_iam_role" "this" {
  name = "CodeBuild_EKS"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "assume_EksCodeBuildKubectlRole" {
  name        = "assume_EksCodeBuildKubectlRole"
  description = "assume_EksCodeBuildKubectlRole"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
          "sts:AssumeRole",
          "sts:SetSourceIdentity",
          "sts:AssumeRoleWithSAML",
          "sts:AssumeRoleWithWebIdentity"
      ],
      "Resource": "arn:aws:iam::398692602192:role/${aws_iam_role.EksCodeBuildKubectlRole.name}"
    },
    {
      "Sid": "VisualEditor1",
      "Effect": "Allow",
      "Action": "sts:DecodeAuthorizationMessage",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_assume_EksCodeBuildKubectlRole" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.assume_EksCodeBuildKubectlRole.arn
}

resource "aws_iam_role_policy_attachment" "attach_ecr" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_role_policy" "this" {
  role = aws_iam_role.this.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterfacePermission"
      ],
      "Resource": [
        "arn:aws:ec2:ap-southeast-1:398692602192:network-interface/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Action": [
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
      ],
      "Resource": [
          "arn:aws:codebuild:ap-southeast-1:398692602192:report-group/*"
      ]
    },
     {
      "Effect": "Allow",
      "Action": [
          "ssm:DescribeParameters",
          "ssm:GetParameters",
          "kms:Decrypt"
      ],
      "Resource": [
          "*"
      ]
    }
  ]
}
POLICY
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow ALl inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all"
  }
}

resource "aws_codebuild_project" "this" {
  name          = "eks-codebuild-devops"
  description   = "CodeBuild Project for EKS DevOps Pipeline"
  build_timeout = "5"
  service_role  = aws_iam_role.this.arn

  artifacts {
    type = "CODEPIPELINE"
    # location = aws_s3_bucket.artifacts.bucket
  }

  cache {
    type = "NO_CACHE"
    # location = aws_s3_bucket.example.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "REPOSITORY_URI"
      value = "398692602192.dkr.ecr.ap-southeast-1.amazonaws.com/eks-devops-nginx"
    }

    environment_variable {
      name  = "EKS_KUBECTL_ROLE_ARN"
      value = aws_iam_role.EksCodeBuildKubectlRole.arn
    }

    environment_variable {
      name  = "EKS_CLUSTER_NAME"
      value = "myEC2TypeDev"
      # value = "prod_eks_cluster"
      type = "PARAMETER_STORE"
    }

    environment_variable {
      name  = "TEST"
      value = "myEC2Key"
      type = "PARAMETER_STORE"
    }

     environment_variable {
      name  = "TEST1"
      value = "/my-app/prod/db-url"
      type = "PARAMETER_STORE"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.this.name
      stream_name = "eks-codebuild-log-stream"
    }

    s3_logs {
      status = "DISABLED"
      # location = "${aws_s3_bucket.example.id}/build-log"
    }
  }

  source {
    type = "CODEPIPELINE"
    # location        = "https://git-codecommit.ap-southeast-1.amazonaws.com/v1/repos/eks-devops-nginx"
    # git_clone_depth = 1

    # git_submodules_config {
    #   fetch_submodules = true
    # }
  }

  source_version = "master"

  vpc_config {
    vpc_id = var.vpc_id

    subnets = var.subnets_id

    security_group_ids = [
      aws_security_group.allow_all.id,
    ]
  }

  tags = {
    Environment = "production"
  }
}

# resource "aws_codebuild_project" "project-with-cache" {
#   name           = "test-project-cache"
#   description    = "test_codebuild_project_cache"
#   build_timeout  = "5"
#   queued_timeout = "5"

#   service_role = aws_iam_role.example.arn

#   artifacts {
#     type = "NO_ARTIFACTS"
#   }

#   cache {
#     type  = "LOCAL"
#     modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
#   }

#   environment {
#     compute_type                = "BUILD_GENERAL1_SMALL"
#     image                       = "aws/codebuild/standard:1.0"
#     type                        = "LINUX_CONTAINER"
#     image_pull_credentials_type = "CODEBUILD"

#     environment_variable {
#       name  = "SOME_KEY1"
#       value = "SOME_VALUE1"
#     }
#   }

#   source {
#     type            = "GITHUB"
#     location        = "https://github.com/mitchellh/packer.git"
#     git_clone_depth = 1
#   }

#   tags = {
#     Environment = "Test"
#   }
# }
