terraform {
    required_providers {
        azurerm = {
        source = "hashicorp/azurerm"
        version = "2.60.0"
        }
    }

    backend "azurerm" {
      resource_group_name = "terraform-rg"
      storage_account_name = "statesterraform"
      container_name = "tonkotsu"
      key = "tonkotsu.tfstate"
    }
}

provider "azurerm" {}

resource "random_string" "prefix" {
  length  = 10
  special = false
  upper   = false
}

resource "azurerm_resource_group" "group" {
  name     = "tonkotsu-rg"
  location = var.location
}

resource "azurerm_app_service_plan" "appserviceplan" {
  name                = "${random_string.prefix.result}-plan"
  location            = azurerm_resource_group.group.location
  resource_group_name = azurerm_resource_group.group.name

  kind = "Linux"

  sku {
    tier = "Standard"
    size = "S1"
  }

  reserved = true
}

resource "azurerm_app_service" "dockerapp" {
  name                = "${random_string.prefix.result}-dockerapp"
  location            = azurerm_resource_group.group.location
  resource_group_name = azurerm_resource_group.group.name
  app_service_plan_id = azurerm_app_service_plan.appserviceplan.id

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
  }

  site_config {
    linux_fx_version = "DOCKER|${var.docker_image}"
    always_on        = true
  }

  identity {
    type = "SystemAssigned"
  }
}
