

data "aws_iam_policy_document" "oidc_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.issuer_host_path}:sub"
      values   = [local.service_account_arn]
    }
  }
}

data "aws_iam_policy_document" "route53_access" {
  statement {
    sid    = "Route53UpdateZones"
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
    ]
    resources = var.allowed_zones
  }

  statement {
    sid    = "Route53ListZones"
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "route53_access" {
  name        = "eks-${var.cluster_name}-external-dns-route53-access"
  description = "EKS - Route53 access for external-dns service ($var.cluster_name)"
  path        = "/"
  policy      = data.aws_iam_policy_document.route53_access.json
}

resource "aws_iam_role" "external_dns" {
  name               = "eks-${var.cluster_name}-external-dns"
  assume_role_policy = data.aws_iam_policy_document.oidc_assume.json
  path               = "/"
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "route53_access" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.route53_access.arn
}

resource "kubernetes_service_account" "external_dns" {
  metadata {
    name      = var.service_account
    namespace = var.k8s_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external_dns.arn
    }
  }

  automount_service_account_token = true
}

resource "kubernetes_cluster_role" "external_dns" {
  metadata {
    name = var.service_account
  }

  rule {
    api_groups = [""]
    resources  = ["services", "pods", "nodes", "endpoints"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["networking.istio.io"]
    resources  = ["gateways"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "external_dns" {
  metadata {
    name = var.service_account
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.external_dns.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.external_dns.metadata.0.name
    namespace = kubernetes_service_account.external_dns.metadata.0.namespace
  }
}

resource "kubernetes_deployment" "external_dns" {
  depends_on = [
    kubernetes_cluster_role_binding.external_dns,
  ]

  metadata {
    name      = var.service_account
    namespace = var.k8s_namespace

    labels = {
      # "app"                          = var.service_account
      "app.kubernetes.io/managed-by" = "terraform"
    }

    annotations = {
      # "field.cattle.io/description" = "AWS ALB Ingress Controller"
    }
  }

  spec {

    selector {
      match_labels = {
        "app" = var.service_account
      }
    }

    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          "app" = var.service_account
        }

        # annotations = merge(
        #   {
        #     # Annotation which is only used by KIAM and kube2iam.
        #     # Should be ignored by your cluster if using IAM roles for service accounts, e.g.
        #     # when running on EKS.
        #     "iam.amazonaws.com/role" = aws_iam_role.this.arn
        #   },
        #   var.k8s_pod_annotations
        # )
      }

      spec {
        automount_service_account_token = true

        dns_policy = "ClusterFirst"

        restart_policy = "Always"

        container {
          name              = var.service_account
          image             = local.external_dns_docker_image
          image_pull_policy = "Always"

          args = [
            "--source=service",
            "--source=ingress",
            # "--domain-filter=external-dns-test.my-org.com", # will make ExternalDNS see only the hosted zones matching provided domain, omit to process all available hosted zones
            "--provider=aws",
            # "--policy=upsert-only",   # would prevent ExternalDNS from deleting any records, omit to enable full synchronization
            "--aws-zone-type=public", # only look at public hosted zones (valid values are public, private or no value for both)
            "--registry=txt",
            "--txt-owner-id=my-hostedzone-identifier"
          ]
        }

        security_context {
          fs_group = 65534
        }

        service_account_name             = kubernetes_service_account.external_dns.metadata[0].name
        termination_grace_period_seconds = 60
      }
    }
  }
}
