//Create a Cosmos DB account
resource "azurerm_cosmosdb_account" "cosmosdb_account" {
  name                = "labb2david"
  resource_group_name = local.RGname
  location            = local.RGlocation
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }
  geo_location {
    location          = local.RGlocation
    failover_priority = 0
  }
  depends_on = [azurerm_resource_group.DavidRG]
}

//Create a Cosmos DB database
resource "azurerm_cosmosdb_sql_database" "CosmosDb" {
  name                = "cosmosdbdavid"
  resource_group_name = local.RGname
  account_name        = azurerm_cosmosdb_account.cosmosdb_account.name
  throughput          = 400

  depends_on = [azurerm_cosmosdb_account.cosmosdb_account]
}

//Create a Cosmos DB container
resource "azurerm_cosmosdb_sql_container" "DavidContainer" {
  name                  = "DavidContainer"
  resource_group_name   = local.RGname
  account_name          = azurerm_cosmosdb_account.cosmosdb_account.name
  database_name         = azurerm_cosmosdb_sql_database.CosmosDb.name
  partition_key_path    = "/definition/id"
  partition_key_version = 1
  throughput            = 400


  indexing_policy {
    indexing_mode = "consistent"
  }

}