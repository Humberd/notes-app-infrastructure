locals {
  namespace = "notes-app"

  database = {
    postgres_username = "notes-app"
    postgres_password = "notes-app-server-password"
    postgres_db = "notes-app"
    postgres_url = "notes-app-postgres-postgresql:5432"
  }

  oauth = {
    google = {
      client_id = "1067793070509-ql9gehqqnd5beilia1c0g3jbug023ict.apps.googleusercontent.com"
      client_secret = "kvGawd3Ij47bgXlZ4YiTAmA6"
    }
    github = {
      client_id = "a6cf03a0f5c1d72ab91f"
      client_secret = "35565a3a2b9ad6add496d0c5b981e9c3e825938b"
    }
  }

  jwt_secret = "my-secret-secret"
}

resource "kubernetes_namespace" "notes-app-namespace" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = local.namespace
  }
}

resource "helm_release" "postgres" {
  repository = "https://charts.bitnami.com/bitnami"
  chart = "postgresql"
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

          env {
            name = "OAUTH_GOOGLE_CLIENT_ID"
            value = local.oauth.google.client_id
          }

          env {
            name = "OAUTH_GOOGLE_CLIENT_SECRET"
            value = local.oauth.google.client_secret
          }

          env {
            name = "OAUTH_GITHUB_CLIENT_ID"
            value = local.oauth.github.client_id
          }

          env {
            name = "OAUTH_GITHUB_CLIENT_SECRET"
            value = local.oauth.github.client_secret
          }

          env {
            name = "JWT_SECRET"
            value = local.jwt_secret
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "notes-app-server" {
  metadata {
    name = "notes-app-server"
    namespace = local.namespace
  }
  spec {
    selector = {
      type = "notes-app-server-instance"
    }
    port {
      port = 8080
    }
  }
}

resource "kubernetes_ingress" "notes-app-server" {
  metadata {
    name = "notes-app-server-ingress"
    namespace = local.namespace
    annotations = {
      "kubernetes.io/ingress.class" = "traefik"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
      "ingress.kubernetes.io/ssl-redirect" = true
    }
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
    tls {
      hosts = ["api.notes-app.humberd.pl"]
      secret_name = "api-notes-app-humberd-pl-tls"
    }
  }
}

