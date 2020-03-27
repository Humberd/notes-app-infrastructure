module "app" {
  source = "../../schema/app"

  create_namespace = true
}

module "load_balancer" {
  source = "../../schema/load_balancer"
}
