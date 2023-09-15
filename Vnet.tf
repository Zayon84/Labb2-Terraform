resource "azurerm_virtual_network" "MyAzureApp" {
  name                = "app-network"
  address_space       = ["10.0.0.0/16"]
  location            = local.RGlocation
  resource_group_name = local.RGname
  depends_on = [ azurerm_resource_group.DavidRG ]
}

resource "azurerm_subnet" "WebAppsSubnet" {
  name                 = "WebApps-subnet"
  resource_group_name  = local.RGname
  virtual_network_name = azurerm_virtual_network.MyAzureApp.name
  address_prefixes     = ["10.0.1.0/24"]

  depends_on = [ azurerm_virtual_network.MyAzureApp ]
}

resource "azurerm_app_service_slot_virtual_network_swift_connection" "Stage_Subnet" {
  slot_name      = azurerm_windows_web_app_slot.Stage.name
  app_service_id = azurerm_windows_web_app.DavidWA.id
  subnet_id      = azurerm_subnet.WebAppsSubnet.id
  depends_on = [ azurerm_subnet.WebAppsSubnet, azurerm_windows_web_app.DavidWA ]
}