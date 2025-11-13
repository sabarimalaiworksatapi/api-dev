@description('Key Vault Name')
param keyVaultName string

@description('Location of resources')
param location string = resourceGroup().location

@description('Array of secrets: [{ name: "...", value: "..." }]')
param secrets array

resource kv 'Microsoft.KeyVault/vaults@2023-02-01' = {
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

resource kvSecrets 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = [
  for secret in secrets: {
    name: '${kv.name}/${secret.name}'
    properties: {
      value: secret.value
    }
  }
]
