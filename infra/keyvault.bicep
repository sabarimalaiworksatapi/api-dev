@description('Key Vault Name')
param keyVaultName string

@description('Location for deployment')
param location string = resourceGroup().location

@description('Array of secrets: [{ name: "...", value: "..." }]')
param secrets array

@description('Whether a new Key Vault should be created')
param createNew bool = true

// Reuse existing vault if createNew = false
resource kvExisting 'Microsoft.KeyVault/vaults@2023-02-01' existing = if (!createNew) {
  name: keyVaultName
}

// Create new vault only if createNew = true
resource kv 'Microsoft.KeyVault/vaults@2023-02-01' = if (createNew) {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

// Always reference vault using a variable
var vaultName = createNew ? kv.name : kvExisting.name

// Create secrets inside whichever vault is used
resource kvSecrets 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = [
  for secret in secrets: {
    name: '${vaultName}/${secret.name}'
    properties: {
      value: secret.value
    }
  }
]
