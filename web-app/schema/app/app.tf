locals {
  namespace = "notes-app"
}

resource "kubernetes_deployment" "notes-app-web" {
  metadata {
    name = "notes-app-web"
    namespace = local.namespace
  }
  spec {
    selector {
      match_labels = {
        type = "notes-app-web-instance"
      }
    }
    template {
      metadata {
        labels = {
          type = "notes-app-web-instance"
        }
      }
      spec {
        container {
          name = "angular-instance"
          image = "humberd/notes-app-web:latest"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "notes-app-web" {
  metadata {
    name = "notes-app-web"
    namespace = local.namespace
  }
  spec {
    selector = {
      type = "notes-app-web-instance"
    }
    port {
      port = 80
    }
  }
}

resource "kubernetes_ingress" "notes-app-web" {
  metadata {
    name = "notes-app-web-ingress"
    namespace = local.namespace
    annotations = {
      "kubernetes.io/ingress.class" = "traefik"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
      "ingress.kubernetes.io/ssl-redirect" = true
    }
  }
  spec {
    rule {
      host = "notes-app.humberd.pl"
      http {
        path {
          backend {
            service_name = "notes-app-web"
            service_port = 80
          }
          path = "/"
        }
      }
    }
    tls {
      hosts = ["notes-app.humberd.pl"]
      secret_name = "notes-app-humberd-pl-tls"
    }
  }
}
