param accessPolicies array
param enabledForDeployment bool
param enabledForDiskEncryption bool
param enabledForTemplateDeployment bool
param softDeleteRetentionInDays int
param enableRbacAuthorization bool
param networkAcls object
param enableSoftDelete bool
param location string
param vaultName string
param tenantID string
param sku string

resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: vaultName
  location: location
  properties: {
    tenantId: tenantID
    sku: {
      family: 'A'
      name: sku
    }
    accessPolicies: accessPolicies
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enableRbacAuthorization: enableRbacAuthorization
    networkAcls: networkAcls
    enableSoftDelete: enableSoftDelete
  }
}

output keyVaultName string = keyvault.name
