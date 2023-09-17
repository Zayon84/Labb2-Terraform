resource "azurerm_service_plan" "ASPdavid" {
  name                = "ASPdavid"
  resource_group_name = local.RGname
  location            = local.RGlocation
  os_type             = "Linux"
  sku_name            = "B1"

  depends_on = [ azurerm_resource_group.DavidRG ]
}

resource "azurerm_linux_web_app" "DavidWA" {
  name                = "davidwa"
  resource_group_name = local.RGname
  location            = local.RGlocation
  service_plan_id     = azurerm_service_plan.ASPdavid.id

  site_config {
    application_stack {
      dotnet_version = "7.0"
    }
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"       = "1"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "1"
    "databaseName"               = azurerm_cosmosdb_sql_database.CosmosDb.name
    "containerName"              = azurerm_cosmosdb_sql_container.DavidContainer.name
  }

  connection_string {
    name  = "CosmosDB"
    type  = "Custom"
    value = azurerm_cosmosdb_account.cosmosdb_account.connection_strings[0]
  }

  depends_on = [azurerm_service_plan.ASPdavid]
}

