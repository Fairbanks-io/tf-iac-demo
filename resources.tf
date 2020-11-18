## Digital Ocean Kubernetes Cluster
resource "digitalocean_kubernetes_cluster" "k8s" {
  name         = var.do_cluster_name
  region       = "sfo2"
  auto_upgrade = false
  version      = "1.18.10-do.2"

  node_pool {
    name       = "worker-pool"
    size       = "s-1vcpu-2gb"
    node_count = 3
  }
}


## Nginx Ingress/Load Balancer
resource "helm_release" "ingress" {
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  name       = "ingress"

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-enable-proxy-protocol"
    value = "true"
  }

  set {
    name  = "controller.config.use-proxy-protocol"
    value = "true"
    type  = "string"
  }
  depends_on = [digitalocean_kubernetes_cluster.k8s]
}

data "kubernetes_service" "nginx-ingress-controller" {
  metadata {
    name = "ingress-ingress-nginx-controller"
  }
  depends_on = [helm_release.ingress]
}


## Cloudflare DNS Record
resource "cloudflare_record" "demo" {
  zone_id = var.cloudflare_zone_id
  name    = "demo"
  proxied = true
  value   = data.kubernetes_service.nginx-ingress-controller.load_balancer_ingress.0.ip
  type    = "A"
  ttl     = 1
}


## Demo app release
resource "helm_release" "docker-node-app" {
  repository       = "https://jonfairbanks.github.io/helm-charts"
  chart            = "docker-node-app"
  name             = "docker-node-app"
  namespace        = "docker-node-app"
  create_namespace = "true"
  set {
    name  = "ingress.hosts[0].host"
    value = cloudflare_record.demo.hostname
  }
  set {
    name  = "ingress.hosts[0].paths[0]"
    value = "/"
  }
  set {
    name  = "resources.requests.cpu"
    value = "100m"
  }
  set {
    name  = "image.tag"
    value = "2.0.4"
  }
}
