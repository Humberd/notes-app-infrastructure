module "app" {
  source = "../../schema/app"
}

module "load_balancer" {
  source = "../../schema/load_balancer"
}
