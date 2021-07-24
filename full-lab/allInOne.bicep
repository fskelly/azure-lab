// General Params
targetScope = 'subscription'

param suffix string = 'blah-3'
param subID string = '949ef534-07f5-4138-8b79-aae16a71310c'
param namingConvention string = '${prefix}-${regionShortCode}'
param prefix string = 'flkelly'
param regionShortCode string = 'neu'

//PARAMETERS

// Keyvault Params
//var vaultName = substring('${namingConvention}kv${uniqueString(keyVaultRG().)}',0,23) // must be globally unique
param keyVaultRGLocation string = 'northeurope'
param keyVaultResourceTags object = {
  Environment: 'Dev'
  Project: 'Tutorial'
  Purpose: 'Security'
  IaC: 'Bicep💪'
}
param sku string = 'Standard'
param objectID string = '4ad6d4e3-4556-4135-979d-bdbd3a63f4ef'
param tenantID string = '17ca67c9-6ef2-4396-89dd-c8a769cc1991' //replace with your tenantId
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
param userNameValue string = 'domain-admin-username'
//param userName string
param userPasswordValue string = 'domain-admin-password'
//@secure()
//param userPassword string
param networkAcls object = {
  ipRules: []
  virtualNetworkRules: []
}

// Identity Params
param identityResourceTags object = {
  Environment: 'Dev'
  Project: 'Tutorial'
  Purpose: 'Identity'
  IaC: 'Bicep💪'
}
param rgIdentityLocation string = 'northeurope'
param identityAddressSpacePrefix string = '10.0.0.0/24'
param identityVnetPrefix string = '10.0.0.0/25'
param vmNamePrefix string = 'dc'
param dnsServers array = [
  '168.63.129.16'
]
param count int = 2
param vmSize string = 'Standard_B2ms'
param ahub bool = false
param ntdsSizeGB int = 20
param sysVolSizeGB int = 20
param adminUsername string
@secure()
param localAdminPassword string
param timeZoneId string = 'Eastern Standard Time'
param dscConfigScript string = 'https://github.com/fskelly/azure-lab/releases/download/dsc-scripts/DomainControllerConfig.zip'
param domainFqdn string
param newForest bool = true
param domainAdminUserName string
@secure()
param domainAdminPassword string
param site string = 'Default-First-Site-Name'
param psScriptLocation string = 'https://raw.githubusercontent.com/fskelly/azure-lab/main/scripts/restart-vms/restart-vms.ps1'
param bastionSubnetIpPrefix string = '10.0.0.128/27'

// Connectivity Params
param connectivityRGLocation string = 'northeurope'
param connectivityResourceTags object = {
  Environment: 'Dev'
  Project: 'Tutorial'
  Purpose: 'Hybrid Connectivity'
  IaC: 'Bicep💪'
}
param connectivityAddressSpacePrefix string = '10.1.0.0/24'
param connectivityVnetPrefix string = '10.1.0.0/25'
param connectivityGwPrefix string = '10.1.0.128/27'
param onPremCIDR string = '192.168.1.0/24'
param gwIP string
@secure()
param sharedKey string
param deploySiteToSite bool = true

// VARIABLES

// Keyvault Variables
var keyVaultRGName = '${namingConvention}-secrets-${suffix}'
var vaultName = substring('${namingConvention}kv${uniqueString(keyVaultRG.id)}',0,23)

// Identity Variables
var azRegions = [
  'eastus'
  'eastus2'
  'centralus'
  'southcentralus'
  'usgovvirginia'
  'westus2'
  'westus3'
]
var zones = [for i in range(0, count): contains(azRegions, rgIdentityLocation) ? [
  string(i == 0 || i == 3 || i == 6 ? 1 : i == 1 || i == 4 || i == 7 ? 2 : 3)
] : []]
var identityRGName = '${namingConvention}-identity-${suffix}'
var bastionHostName = '${namingConvention}-adds-bastion'
var bastionSubnetName = 'AzureBastionSubnet'
var publicIpAddressName = '${bastionHostName}-pip'
var domainUserName = newForest == true ? '${split(domainFqdn,'.')[0]}\\${adminUsername}' : domainAdminUsername
var domainPassword = newForest == true ? localAdminPassword : domainAdminPassword
var domainSite = newForest == true ? 'Default-First-Site-Name' : site
var identityVnetName = '${namingConvention}-adds-vnet'
var avSetName = '${namingConvention}-adds-avset-1'
var managedIdentityName = '${namingConvention}-adds-msi1'
var fullManagedIdentityID = '/subscriptions/${subID}/resourceGroups/${identityRG.name}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${managedIdentityName}'
var domainAdminUsername = '${domainAdminUserName}@${domainFqdn}'

// Connectivity Variables
var connectivityRGName = '${namingConvention}-connectivity-${suffix}'
var connectivityVnetName = '${namingConvention}-con-vnet'
var vngName = '${namingConvention}-con-vng'
var dnsName = substring('${namingConvention}-pip-${uniqueString(connectivityRG.id)}',0, 29)
var lngName = '${namingConvention}-con-lng'
var connectivytPipName = substring('${namingConvention}-pip-${uniqueString(connectivityRG.id)}',0, 29)

//Create Resource Groups
resource keyVaultRG 'Microsoft.Resources/resourceGroups@2020-06-01' ={
  name: keyVaultRGName
  location: keyVaultRGLocation
  tags: keyVaultResourceTags
}

resource identityRG 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: identityRGName
  location: rgIdentityLocation
  tags: identityResourceTags
}

resource connectivityRG 'Microsoft.Resources/resourceGroups@2020-06-01' ={
  name: connectivityRGName
  location: connectivityRGLocation
  tags: connectivityResourceTags
}

//MODULES
module keyvault './00-prereqs/keyVault/kv.bicep' = {
  name: 'deploy-keyvault'
  scope: keyVaultRG
  params: {
    accessPolicies: accessPolicies
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enableRbacAuthorization: enableRbacAuthorization
    enableSoftDelete: enableSoftDelete
    location: keyVaultRG.location
    networkAcls: networkAcls
    sku: sku
    softDeleteRetentionInDays: softDeleteRetentionInDays
    tenantID: tenantID
    vaultName: vaultName
  }
  
}

module secrets './00-prereqs/keyVault/secrets.bicep' = {
  name: 'deploy-secrets'
  scope: keyVaultRG
  params: {
    userName: adminUsername
    userPassword: domainAdminPassword
    vaultName: vaultName
    userNameValue: userNameValue
    userPasswordValue: userPasswordValue
  }
  dependsOn: [
    keyvault
  ]
}

module addsVnet '01-adds/adModules/vnet.bicep' = {
  name: 'deploy-vnet'
  scope: identityRG
  params: {
    vnetName: identityVnetName
    addressSpacePrefix: identityAddressSpacePrefix
    vnetPrefix: identityVnetPrefix
    bastionSubnetName: bastionSubnetName
    bastionSubnetIpPrefix: bastionSubnetIpPrefix
    nsgName: 'adds-nsg'
  }
  dependsOn: [
    secrets
  ]
}

module managedIdentity './01-adds/adModules/mi.bicep' = {
  name: 'deploy-managedIdentity'
  scope: identityRG
  params: {
    managedIdentityName: managedIdentityName
  }
  
}

module avSet './01-adds/adModules/avset.bicep' = {
  name: 'deploy-avset'
  scope: identityRG
  params :{
    avSetName: avSetName
  }  
}

module bastionPublicIp './01-adds/adModules/pip.bicep' = {
  name: 'deploy-pip'
  scope: identityRG
  params: {
    location: rgIdentityLocation
    publicIpAddressName: publicIpAddressName

  }
}

module bastionHost './01-adds/adModules/bastion.bicep' = {
  name: 'deploy-bastionHost'
  scope: identityRG
  params: {
    bastionHostName: bastionHostName
    bastionSubnetID: addsVnet.outputs.bastionSubnetID
    location: rgIdentityLocation
    publicIpID: bastionPublicIp.outputs.publicIpID
  }
  dependsOn: [
    addsVnet
  ]
}

module nics './01-adds/adModules/nics.bicep' = [for i in range(0, count): {
  name: '${vmNamePrefix}-${i + 1}-nic'
  scope: identityRG
  params: {
    vmNamePrefix: vmNamePrefix
    vnetID: addsVnet.outputs.vnetID
    //count: count
    i: i
    subnetName: addsVnet.outputs.subnetName
    
  }
}]

module nicsDns './01-adds/adModules/nicDns.bicep' = {
  name: 'set-dns-nic'
  scope: identityRG
  params: {
    dnsServers: dnsServers
    nics: [for i in range(0, count): {
      name: nics[i].name
      ipConfigurations: nics[i].outputs.ipConfiguration
    }]
    count: count
    location: rgIdentityLocation
  }
}

module vmProperties './01-adds/adModules/vmPropertiesBuilder.bicep' = {
  name: 'deploy-Properties-Builder'
  scope: identityRG
  params: {
    ahub: ahub
    avsetId: avSet.outputs.avSetID
    count: count
    localAdminPassword: localAdminPassword
    localAdminUsername: adminUsername
    nics: [for i in range(0, count): {
      id: nicsDns.outputs.nicIds[i].id
    }]
    ntdsSizeGB: ntdsSizeGB
    sysVolSizeGB: sysVolSizeGB
    timeZoneId: timeZoneId
    vmNamePrefix: vmNamePrefix
    vmSize: vmSize
    zones: zones[0]
  }
}

module dcConfigurationBuild './01-adds/adModules/configureDCs.bicep' = {
  name: 'deploy-dcs'
  scope: identityRG
  params: {
    domainFqdn: domainFqdn
    domainPassword: domainPassword
    domainSite: domainSite
    domainUserName: domainUserName
    dscConfigScript: dscConfigScript
    fullManagedIdentityID: fullManagedIdentityID
    location: rgIdentityLocation
    newForest: newForest
    psScriptLocation: psScriptLocation
    vmNamePrefix: vmNamePrefix
    zones: zones
    dc1Properties: vmProperties.outputs.vmProperties[0]
    dc2Properties: vmProperties.outputs.vmProperties[1]
  }
  
}

module connectivityVnet './02-connectivity/p2sModules/network.bicep' = {
  name: 'deploy-connectivity-vnet'
  scope: connectivityRG
  params: {
    vnetName: connectivityVnetName
    addressSpacePrefix: connectivityAddressSpacePrefix
    vnetPrefix: connectivityVnetPrefix
    gwPrefix: connectivityGwPrefix
  }
  dependsOn: [
    connectivityRG
  ]
}

module vng './02-connectivity/p2sModules/vng.bicep' = {
  name: 'vng-deploy'
  scope: connectivityRG
  params: {
    gwSubnetName: 'gatewaySubnet'
    vnetName: connectivityVnetName
    vngName: vngName
    pipName: connectivytPipName
  }
  dependsOn: [
    pip
  ]
}

module pip './02-connectivity/p2sModules/pip.bicep' = {
  name: 'pip-deploy'
  scope: connectivityRG
  params: {
    pipName: connectivytPipName
    dnsName: dnsName
  }
}

module lng './02-connectivity/s2sModules/lng.bicep' = if (deploySiteToSite == true){
  name: 'lng-deploy'
  scope: connectivityRG
  params: {
    lngName: lngName
    onPremCIDR: onPremCIDR
    gateway: gwIP
  }
  dependsOn: [
    pip
  ]
}

module connection './02-connectivity/s2sModules/connection.bicep' = if (deploySiteToSite == true){
  name: 'deploy-connection'
  scope: connectivityRG
  params: {
    connectionName: 'azure-to-home'
    lngName: lngName
    vngName: vngName
    sharedKey: sharedKey
  }
  dependsOn:[
    vng
  ]
}

module connectivity2idenityPeering './02-connectivity/peeringModules/connectivity2idenityPeering.bicep' = {
  name: 'deploy-connectivity2identitypeering'
  scope: connectivityRG
  params: {
    connectivityVnetName: connectivityVnetName
    identityVnetID: addsVnet.outputs.vnetID
    identityVnetName: identityVnetName
  }
  dependsOn:[
    vng
  ]
} 

module identity2connectiivtyPeering './02-connectivity/peeringModules/identity2connectivityPeering.bicep' = {
  name: 'spoke2ConnectivityHubPeering'
  scope: identityRG
  params: {
    connectivityVnetID: connectivityVnet.outputs.vnetID
    connectivityVnetName: connectivityVnetName
    identityVnetName: identityVnetName
  }
  dependsOn:[
    vng
  ]
}

//output spokeVnetID string = spokeVnet.outputs.spokeVnetId
//output connectivityHubVnetID string = hubVnet.outputs.connectivityHubVnetID
//output pipName string = connectivytPipName
//output vngPIP string = pip.outputs.pipIP
//output sharedKey string = sharedKey
//output username string = domainUserName
output logonName string = '${adminUsername}@${domainFqdn}'
//output identityVnetName string = identityVnetName
//output vnetID string = connectivityVnetName.outputs.vnetID
//output subnetName string = addsVnet.outputs.subnetName
//output identityRGName string = identityRG.name
