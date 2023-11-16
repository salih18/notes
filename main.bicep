// Define custom types for clarity and reusability
type StorageAccountSkuType = 'Standard_LRS' | 'Standard_GRS'

type StorageAccountConfigType = object({
  name: string
  sku: StorageAccountSkuType
  location: string
})

type KeyVaultConfigType = {
  name: string
  location: string
}

// Parameters using custom types
param storageAccountConfig StorageAccountConfigType
param keyVaultConfig KeyVaultConfigType

// Azure Storage Account Resource
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountConfig.name
  location: storageAccountConfig.location
  sku: {
    name: storageAccountConfig.sku
  }
  kind: 'StorageV2'
}

// Azure Key Vault Resource
resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultConfig.name
  location: keyVaultConfig.location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
  }
}


type storageAccountConfigType = object({
  name: string
  sku: storageAccountSkuType
})
