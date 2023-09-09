terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.20.0"
    }
  }
}

provider "kubernetes" {
  #config_path            = base64decode(aws_eks_cluster.my_cluster.certificate_authority.0.data)
  host                   = aws_eks_cluster.my_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.my_cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.my_cluster_auth.token
}

/*
data "kubernetes_namespace" "consul_ns" {
  metadata {
    name = var.namespace
  }
}
*/

resource "kubernetes_namespace" "consul" {
 # count = data.kubernetes_namespace.consul_ns == "consul" ? 0 : 1
  metadata {
    annotations = {
      name = "consul"
    }

    labels = {
      mylabel = "consul"
    }

    name = "consul"
  }

  depends_on = [aws_eks_cluster.my_cluster, aws_iam_role_policy_attachment.eks_nodegroup]
}

resource "kubernetes_secret" "consul_license" {
  metadata {
    name      = "consul-license-secret"
    namespace = "consul"
  }

  data = {
    license = file(var.license_file)
  }

  depends_on = [aws_eks_cluster.my_cluster, aws_eks_node_group.my_node_group]
}
