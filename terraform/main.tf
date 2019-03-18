terraform {
    required_version = ">= 0.11, < 0.12"
    backend "s3" {
        skip_requesting_account_id = true
        skip_credentials_validation = true
        skip_get_ec2_platforms = true
        skip_metadata_api_check = true
    }
}

variable do_token {}

provider "digitalocean" {
    token = "${var.do_token}"
}

resource "digitalocean_kubernetes_cluster" "cicd" {
    name = "cicd"
    region = "nyc1"
    version = "1.12.1-do.2"
    node_pool {
        name = "worker-pool"
        size = "s-2vcpu-2gb"
        node_count = 1
    }
}

locals {
    k8s_config = "${digitalocean_kubernetes_cluster.cicd.kube_config[0]}"
    k8s_host = "${local.k8s_config["host"]}"
    k8s_client_key = "${base64decode(local.k8s_config["client_key"])}"
    k8s_client_cert = "${base64decode(local.k8s_config["client_certificate"])}"
    k8s_ca_cert = "${base64decode(local.k8s_config["cluster_ca_certificate"])}"
}

provider "kubernetes" {
    host = "${local.k8s_host}"
    client_certificate = "${local.k8s_client_cert}"
    client_key = "${local.k8s_client_key}"
    cluster_ca_certificate = "${local.k8s_ca_cert}"
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name = "tiller"
    namespace = "kube-system"
  }
  automount_service_account_token = true
}

resource "kubernetes_cluster_role_binding" "tiller" {
    metadata {
        name = "tiller"
    }
    role_ref {
        kind = "ClusterRole"
        name = "cluster-admin"
        api_group = "rbac.authorization.k8s.io"
    }
    subject {
        kind = "ServiceAccount"
        name = "tiller"
        api_group = ""
        namespace = "kube-system"
    }
}

provider "helm" {
    #enable_tls = true
    #client_certificate = "${local.k8s_client_cert}"
    #client_key = "${local.k8s_client_key}"
    #ca_certificate = "${local.k8s_ca_cert}"
    tiller_image = "gcr.io/kubernetes-helm/tiller:v2.11.0"
    service_account = "${kubernetes_service_account.tiller.metadata.0.name}"
    namespace = "${kubernetes_service_account.tiller.metadata.0.namespace}"
    kubernetes {
        host = "${local.k8s_host}"
        client_certificate = "${local.k8s_client_cert}"
        client_key = "${local.k8s_client_key}"
        cluster_ca_certificate = "${local.k8s_ca_cert}"
    }
}

data "helm_repository" "stable" {
    name = "stable"
    url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "drone" {
    name = "drone"
    chart = "stable/drone"
    set {
        name  = "some_key"
        value = "foo"
    }
    depends_on = [
        "data.helm_repository.stable",
        "kubernetes_service_account.tiller",
        "kubernetes_cluster_role_binding.tiller",
    ]
}
