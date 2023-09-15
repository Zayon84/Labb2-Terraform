resource "azurerm_service_plan" "ASPdavid" {
  name                = "ASPdavid"
  resource_group_name = local.RGname
  location            = local.RGlocation
  sku_name            = "P1v3"
  os_type             = "Windows"
  depends_on = [ azurerm_resource_group.DavidRG ]
}

resource "azurerm_windows_web_app" "DavidWA" {
  name                = "davidwa"
  resource_group_name = local.RGname
  location            = local.RGlocation
  service_plan_id     = azurerm_service_plan.ASPdavid.id

  site_config {
    application_stack {
      current_stack = "dotnet"
      dotnet_version = "v7.0"
    }
  }
  logs { # We add this after we fix the storage account sas token url
    detailed_error_messages = true
        http_logs {
            azure_blob_storage {
              retention_in_days = 5
              sas_url = "https://${azurerm_storage_account.WebappLoggs.name}.blob.core.windows.net/${azurerm_storage_container.Webappcontainer.name}${data.azurerm_storage_account_blob_container_sas.accountsas.sas}"
            }
      
    }
    
  }

  depends_on = [ azurerm_service_plan.ASPdavid ]
}

#3 Web app slot
/*
resource "azurerm_windows_web_app_slot" "Production" {
  name           = "production-slot"
  app_service_id = azurerm_windows_web_app.DavidWA.id

  site_config {
    application_stack {
      current_stack = "dotnet"
      dotnet_version = "v7.0"
    }
  }

  depends_on = [ azurerm_windows_web_app.DavidWA ]
}
*/
resource "azurerm_windows_web_app_slot" "Stage" {
  name           = "stage-slot"
  app_service_id = azurerm_windows_web_app.DavidWA.id

  site_config {
    application_stack {
      current_stack = "dotnet"
      dotnet_version = "v7.0"
    }
  }
  depends_on = [ azurerm_windows_web_app.DavidWA ]
}

resource "azurerm_windows_web_app_slot" "LastGood" {
  name           = "lastgood-slot"
  app_service_id = azurerm_windows_web_app.DavidWA.id

  site_config {
    application_stack {
      current_stack = "dotnet"
      dotnet_version = "v7.0"
    }
  }
  depends_on = [ azurerm_windows_web_app.DavidWA ]
}

resource "azurerm_source_control_token" "token" {
  type  = "GitHub"
  token = "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"
  depends_on = [ azurerm_resource_group.DavidRG ]
}

resource "azurerm_app_service_source_control" "production_code" {
  app_id   = azurerm_windows_web_app.DavidWA.id
  repo_url = "https://github.com/abdelilahAchir/App"
  branch   = "master"
  depends_on = [ azurerm_windows_web_app.DavidWA , 
                    azurerm_source_control_token.token]
}

resource "azurerm_app_service_source_control_slot" "Stage_code" {
  slot_id    = azurerm_windows_web_app_slot.Stage.id
  repo_url = "https://github.com/abdelilahAchir/App"
  branch   = "master"
  depends_on = [ azurerm_windows_web_app_slot.Stage, 
                    azurerm_source_control_token.token ]
}

resource "azurerm_app_service_source_control_slot" "LastGood_code" {
  slot_id   = azurerm_windows_web_app_slot.LastGood.id
  repo_url = "https://github.com/abdelilahAchir/App"
  branch   = "master"
  depends_on = [ azurerm_windows_web_app_slot.LastGood, 
                    azurerm_source_control_token.token ]
}

