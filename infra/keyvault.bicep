@description('Key Vault Name')
param keyVaultName string

@description('Location')
param location string = resourceGroup().location

@description('Dictionary of secrets')
param secrets object

resource kv 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    enableRbacAuthorization: true
  }
}

resource kvSecrets 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = [
  for secretName in keys(secrets): {
    name: '${kv.name}/${secretName}'
    properties: {
      value: secrets[secretName]
    }
  }
]
