param prefix string
param regionShortCode string
//param rgName string

param namingConvention string = '${prefix}${regionShortCode}'
param vaultName string = substring('f-${namingConvention}kv${uniqueString(resourceGroup().id)}',0,23) // must be globally unique
param location string = resourceGroup().location
param sku string = 'Standard'
param objectID string
param tenantID string //= '' replace with your tenantId
param accessPolicies array = [
  {
    tenantId: tenantID
    objectId: objectID // replace with your objectId
    permissions: {
      keys: [
        'Get'
        'List'
        'Update'
        'Create'
        'Import'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
      ]
      secrets: [
        'Get'
        'List'
        'Set'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
      ]
      certificates: [
        'Get'
        'List'
        'Update'
        'Create'
        'Import'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
        'ManageContacts'
        'ManageIssuers'
        'GetIssuers'
        'ListIssuers'
        'SetIssuers'
        'DeleteIssuers'
      ]
    }
  }
]

param enabledForDeployment bool = true
param enabledForTemplateDeployment bool = true
param enabledForDiskEncryption bool = true
param enableRbacAuthorization bool = false
param softDeleteRetentionInDays int = 90
param enableSoftDelete bool = false

// domain admin key
//var keyName = '${prefix}-${regionShortCode}-secrets-kv'
//var userNameKeyName = '${prefix}-${regionShortCode}-admin-username'
param userNameValue string = 'domain-admin-username'
param userName string

// domain admin password key
//var userNamePasswordKeyName = '${prefix}-${regionShortCode}-admin-password'
param userPasswordValue string = 'domain-admin-password'
@secure()
param userPassword string

param networkAcls object = {
  ipRules: []
  virtualNetworkRules: []
}

module keyvault './keyVault/kv.bicep' = {
  name: 'deploy-keyvault'
  params: {
    accessPolicies: accessPolicies
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enableRbacAuthorization: enableRbacAuthorization
    enableSoftDelete: enableSoftDelete
    location: location
    networkAcls: networkAcls
    sku: sku
    softDeleteRetentionInDays: softDeleteRetentionInDays
    tenantID: tenantID
    vaultName: vaultName
  }
  
}

module secrets './keyVault/secrets.bicep' = {
  name: 'deploy-secrets'
  params: {
    userName: userName
    userPassword: userPassword
    vaultName: vaultName
    userNameValue: userNameValue
    userPasswordValue: userPasswordValue
  }
  dependsOn: [
    keyvault
  ]
  
}
