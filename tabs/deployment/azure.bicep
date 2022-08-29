param resourceBaseName string
param storageName string = '${resourceBaseName}tab'
param storageSku string = 'Standard_LRS'
param location string = resourceGroup().location

// Azure Storage that hosts your static web site
resource storage 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  kind: 'StorageV2'
  location: location
  name: storageName
  properties: {
    supportsHttpsTrafficOnly: true
  }
  sku: {
    name: storageSku
  }
}

// The output will be persisted in .fx/.env.{envName}
output CLOUD_TAB_RESOURCE_ID string = storage.id // used in deploy stage
output CLOUD_TAB_DOMAIN string = storage.properties.primaryEndpoints.web
