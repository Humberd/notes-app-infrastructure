provider "kubernetes" {
  load_config_file = false
  host = var.kubernetes_host
  cluster_ca_certificate = base64decode(var.kubernetes_cluster_ca_certificate)
  token = base64decode(var.kubernetes_token)
}

provider "helm" {
  kubernetes {
    load_config_file = false
    host = var.kubernetes_host
    cluster_ca_certificate = base64decode(var.kubernetes_cluster_ca_certificate)
    token = base64decode(var.kubernetes_token)
  }

  version = "1.1.1"
}

module "app" {
  source = "../../schema/app"
}
