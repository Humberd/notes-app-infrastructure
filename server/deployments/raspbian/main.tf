provider "kubernetes" {
  load_config_file = false
  host = "https://humberd.pl"

}

module "app" {
  source = "../../schema/app"
}
