locals {
  namespace = "notes-app"

  database = {
    postgres_username = "notes-app"
    postgres_password = "notes-app-server-password"
    postgres_db = "notes-app"
    postgres_url = "notes-app-postgres-postgresql.notes-app.svc.cluster.local:5432"
  }
}

resource "kubernetes_namespace" "notes-app-namespace" {
  metadata {
    name = local.namespace
  }
}

data "helm_repository" "postgres-repo" {
  depends_on = [
    kubernetes_namespace.notes-app-namespace
  ]

  name = "bitnami"
  url = "https://charts.bitnami.com/bitnami"
}

resource "helm_release" "postgres" {
  depends_on = [
    data.helm_repository.postgres-repo
  ]

  chart = "bitnami/postgresql"
  name = "notes-app-postgres"
  namespace = local.namespace

  set {
    name = "image.repository"
    value = "postgres"
  }

  set {
    name = "image.tag"
    value = "12.2"
  }

  set {
    name = "postgresqlUsername"
    value = local.database.postgres_username
  }

  set {
    name = "postgresqlPassword"
    value = local.database.postgres_password
  }

  set {
    name = "postgresqlDatabase"
    value = local.database.postgres_db
  }
}

resource "kubernetes_deployment" "notes-app-server" {
  depends_on = [
    helm_release.postgres
  ]

  metadata {
    name = "notes-app-server"
    namespace = local.namespace
  }
  spec {
    selector {
      match_labels = {
        type = "notes-app-server-instance"
      }
    }
    template {
      metadata {
        labels = {
          type = "notes-app-server-instance"
        }
      }
      spec {
        container {
          name = "kotlin-instance"
          image = "humberd/notes-app-server:latest"

          port {
            container_port = 8080
          }

          env {
            name = "POSTGRES_URL"
            value = local.database.postgres_url
          }

          env {
            name = "POSTGRES_DB"
            value = local.database.postgres_db
          }

          env {
            name = "POSTGRES_USERNAME"
            value = local.database.postgres_username
          }

          env {
            name = "POSTGRES_PASSWORD"
            value = local.database.postgres_password
          }

        }
      }
    }
  }
}

resource "helm_release" "ingress-controller" {
  chart = "stable/nginx-ingress"
  name = "nginx-ingress"
  namespace = local.namespace

  set {
    name = "controller.publishService.enabled"
    value = true
  }
}

resource "kubernetes_service" "notes-app-server" {
  metadata {
    name = "notes-app-server"
    namespace = local.namespace
  }
  spec {
    port {
      port = 8080
    }

    selector = {
      type = "notes-app-server-instance"
    }
  }
}

resource "kubernetes_ingress" "notes-app-server" {
  metadata {
    name = "notes-app-server-ingress"
    namespace = local.namespace
  }
  spec {
    rule {
      host = "api.notes-app.humberd.pl"
      http {
        path {
          backend {
            service_name = "notes-app-server"
            service_port = 8080
          }
          path = "/"
        }
      }
    }
  }
}

