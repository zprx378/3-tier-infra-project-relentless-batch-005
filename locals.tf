locals {
  project_tags = {
    contact      = "devops@uaicei.com"
    application  = "Jupiter"
    project      = "uaicei"
    environment  = "${terraform.workspace}" # refers to your current workspace (dev, prod, etc)
    creationTime = timestamp()
  }
}