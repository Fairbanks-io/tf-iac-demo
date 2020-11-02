provider "digitalocean" {
  token             = var.do_token
  spaces_access_id  = var.do_access_id
  spaces_secret_key = var.do_secret_key
}

provider "helm" {
  kubernetes {
    load_config_file       = false
    host                   = digitalocean_kubernetes_cluster.k8s.endpoint
    token                  = digitalocean_kubernetes_cluster.k8s.kube_config.0.token
    cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
  }
}

provider "kubernetes" {
  load_config_file       = false
  host                   = digitalocean_kubernetes_cluster.k8s.endpoint
  token                  = digitalocean_kubernetes_cluster.k8s.kube_config.0.token
  cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)

}

provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}