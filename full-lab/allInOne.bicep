// General Params
targetScope = 'subscription'

// you can uncomment suffix and use if needed - I added it to naming convention while i was testing.
//param suffix string
param subID string
//param namingConvention string = '${prefix}-${regionShortCode}'
@maxLength(3)
@minLength(2)
param prefix string

// Deployment Params - which components do you want to deploy?
param dryRun bool = false // run a test script?
param deployIdentity bool = true // do you want to deploy identity?
param deployKeyVault bool = true // do you want to deploy keyvault?
param deployConnectivity bool = true // do you want to deploy connectivity?

//PARAMETERS

// Keyvault Params
param keyVaultRGLocation string
param keyVaultResourceTags object = {
  Environment: 'Dev'
  Project: 'Tutorial'
  Purpose: 'Security'
  IaC: 'Bicep💪'
}
param sku string = 'Standard'
param objectID string       //replace with your objectId
param tenantID string      //replace with your tenantId
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
param userPasswordValue string = 'domain-admin-password'
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
param identityRGLocation string
param identityAddressSpacePrefix string = '10.0.0.0/24'
param identityVnetPrefix string = '10.0.0.0/25'
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
param connectivityRGLocation string
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
param skuTier string = 'VpnGw1AZ'
param skuName string = 'VpnGw1AZ'

// VARIABLES

//Global

//var namingConvention = '${prefix}-${regionShortCode}'

// Keyvault Variables
var keyVaultRGName = '${prefix}-secret'
//var keyVaultRGName = '${namingConvention}-secrets'
//regionShortName

// Leaving in place so this variable can be used instead
//var vaultName = substring('${namingConvention}kv${uniqueString(keyVaultRG.id)}',0,23)
//var vaultName = substring('${prefix}-${keyVaultShortCode.outputs.regionShortName}kv${uniqueString(keyVaultRG.id)}',0,23)
var vaultName = substring('${prefix}-${keyVaultShortCode.outputs.regionShortName}kv${uniqueString(keyVaultRG.id)}',0,22)
//var vaultName = substring('${namingConvention}kv${uniqueString(keyVaultRG.id)}',0,23)

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
var zones = [for i in range(0, count): contains(azRegions, identityRGLocation) ? [
  string(i == 0 || i == 3 || i == 6 ? 1 : i == 1 || i == 4 || i == 7 ? 2 : 3)
] : []]
var identityRGName = '${prefix}-identity'

// Some original names left as samples 

//var bastionHostName = '${namingConvention}-adds-bastion'
var bastionHostName = '${prefix}-${idShortCode.outputs.regionShortName}-adds-bastion'
var bastionSubnetName = 'AzureBastionSubnet'
var publicIpAddressName = '${bastionHostName}-pip'
var domainUserName = newForest == true ? '${split(domainFqdn,'.')[0]}\\${adminUsername}' : domainAdminUsername
var domainPassword = newForest == true ? localAdminPassword : domainAdminPassword
var domainSite = newForest == true ? 'Default-First-Site-Name' : site
var identityVnetName = '${prefix}-${idShortCode.outputs.regionShortName}-adds-vnet'
var avSetName = '${prefix}-${idShortCode.outputs.regionShortName}-adds-avset-1'
var managedIdentityName = '${prefix}-${idShortCode.outputs.regionShortName}-adds-msi1'
var fullManagedIdentityID = '/subscriptions/${subID}/resourceGroups/${identityRG.name}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${managedIdentityName}'
var domainAdminUsername = '${domainAdminUserName}@${domainFqdn}'
var dcNamePrefix = '${idShortCode.outputs.regionShortName}-ad-vm'

// Connectivity Variables
var connectivityRGName = '${prefix}-connectivity'
var connectivityVnetName = '${prefix}-${conShortCode.outputs.regionShortName}-con-vnet'
var vngName = '${prefix}-${conShortCode.outputs.regionShortName}-con-vng'
var dnsName = substring('${prefix}-${conShortCode.outputs.regionShortName}-pip-${uniqueString(connectivityRG.id)}',0, 25)
var lngName = '${prefix}-${conShortCode.outputs.regionShortName}-con-lng'
var connectivytPipName = substring('${prefix}-${conShortCode.outputs.regionShortName}-pip-${uniqueString(connectivityRG.id)}',0, 29)
var useRemoteGateways = (deploySiteToSite == true ? true : false)

//Create Resource Groups
resource keyVaultRG 'Microsoft.Resources/resourceGroups@2020-06-01' = if(!dryRun && deployKeyVault){
  name: keyVaultRGName
  location: keyVaultRGLocation
  tags: keyVaultResourceTags
}

resource identityRG 'Microsoft.Resources/resourceGroups@2020-06-01' = if(!dryRun  && deployIdentity) {
  name: identityRGName
  location: identityRGLocation
  tags: identityResourceTags
}

resource connectivityRG 'Microsoft.Resources/resourceGroups@2020-06-01' = if(!dryRun && deployConnectivity) {
  name: connectivityRGName
  location: connectivityRGLocation
  tags: connectivityResourceTags
}

//MODULES

//KEYVAULT MODULES

module keyVaultShortCode './tools/regionShortCode.bicep' = if(!dryRun && deployKeyVault) {
  name: 'get-keyvault-shortcode'
  scope: keyVaultRG
  params: {
    region: keyVaultRGLocation
  }
}

module idShortCode './tools/regionShortCode.bicep' = if(!dryRun && deployIdentity) {
  name: 'get-id-shortcode'
  scope: identityRG
  params: {
    region: identityRGLocation
  }
}

module conShortCode './tools/regionShortCode.bicep' = if(!dryRun && deployConnectivity) {
  name: 'get-con-shortcode'
  scope: connectivityRG
  params: {
    region: connectivityRGLocation
  }
}

module keyvault './00-prereqs/keyVault/kv.bicep' = if(!dryRun && deployKeyVault) {
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

module secrets './00-prereqs/keyVault/secrets.bicep' = if(!dryRun && deployKeyVault) {
  name: 'deploy-secrets'
  scope: keyVaultRG
  params: {
    userName: adminUsername
    userPassword: domainAdminPassword
    vaultName: keyvault.outputs.keyVaultName
    userNameValue: userNameValue
    userPasswordValue: userPasswordValue
  }
  dependsOn: [
    keyvault
  ]
}

// ADDS MODULES

module addsVnet '01-adds/adModules/vnet.bicep' = if(!dryRun && deployIdentity) {
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

module managedIdentity './01-adds/adModules/mi.bicep' = if(!dryRun  && deployIdentity) {
  name: 'deploy-managedIdentity'
  scope: identityRG
  params: {
    managedIdentityName: managedIdentityName
  }
  
}

module avSet './01-adds/adModules/avset.bicep' = if(!dryRun  && deployIdentity) {
  name: 'deploy-avset'
  scope: identityRG
  params :{
    avSetName: avSetName
  }  
}

module bastionPublicIp './01-adds/adModules/pip.bicep' = if(!dryRun  && deployIdentity) {
  name: 'deploy-pip'
  scope: identityRG
  params: {
    location: identityRGLocation
    publicIpAddressName: publicIpAddressName

  }
}

module bastionHost './01-adds/adModules/bastion.bicep' = if(!dryRun  && deployIdentity) {
  name: 'deploy-bastionHost'
  scope: identityRG
  params: {
    bastionHostName: bastionHostName
    bastionSubnetID: addsVnet.outputs.bastionSubnetID
    location: identityRGLocation
    publicIpID: bastionPublicIp.outputs.publicIpID
  }
  dependsOn: [
    addsVnet
  ]
}

module nics './01-adds/adModules/nics.bicep' = [for i in range(0, count): {
  name: 'ad-${i + 1}-nic'
  scope: identityRG
  params: {
    dryRun: dryRun
    deployIdentity: deployIdentity
    //vmNamePrefix: dcNamePrefix
    vnetID: addsVnet.outputs.vnetID
    i: i
    subnetName: addsVnet.outputs.subnetName
    shortCode: idShortCode.outputs.regionShortName
    prefix: prefix
  }
}]

module nicsDns './01-adds/adModules/nicDns.bicep' = if(!dryRun  && deployIdentity) {
  name: 'set-dns-nic'
  scope: identityRG
  params: {
    dnsServers: dnsServers
    nics: [for i in range(0, count): {
      name: nics[i].name
      ipConfigurations: nics[i].outputs.ipConfiguration
    }]
    count: count
    location: identityRGLocation
  }
}

module vmProperties './01-adds/adModules/vmPropertiesBuilder.bicep' = if(!dryRun  && deployIdentity) {
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
    vmNamePrefix: dcNamePrefix
    vmSize: vmSize
    zones: zones[0]
  }
}

module dcConfigurationBuild './01-adds/adModules/configureDCs.bicep' = if(!dryRun  && deployIdentity) {
  name: 'deploy-dcs'
  scope: identityRG
  params: {
    domainFqdn: domainFqdn
    domainPassword: domainPassword
    domainSite: domainSite
    domainUserName: domainUserName
    dscConfigScript: dscConfigScript
    fullManagedIdentityID: fullManagedIdentityID
    location: identityRGLocation
    newForest: newForest
    psScriptLocation: psScriptLocation
    vmNamePrefix: dcNamePrefix
    zones: zones
    dc1Properties: vmProperties.outputs.vmProperties[0]
    dc2Properties: vmProperties.outputs.vmProperties[1]
  }
  
}

//Connectivity Modules

module connectivityVnet './02-connectivity/p2sModules/network.bicep' = if(!dryRun && deployConnectivity) {
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

module vng './02-connectivity/p2sModules/vng.bicep' = if(!dryRun && deployConnectivity) {
  name: 'vng-deploy'
  scope: connectivityRG
  params: {
    gwSubnetName: 'gatewaySubnet'
    vnetName: connectivityVnetName
    vngName: vngName
    pipName: connectivytPipName
    skuName: skuName
    skuTier: skuTier
  }
  dependsOn: [
    pip
  ]
}

module pip './02-connectivity/p2sModules/pip.bicep' = if(!dryRun && deployConnectivity) {
  name: 'pip-deploy'
  scope: connectivityRG
  params: {
    pipName: connectivytPipName
    dnsName: dnsName
    skuName: 'standard'
  }

}

module lng './02-connectivity/s2sModules/lng.bicep' = if (deploySiteToSite == true && !dryRun && deployConnectivity){
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

module connection './02-connectivity/s2sModules/connection.bicep' = if (deploySiteToSite == true && dryRun == false && deployConnectivity == true){
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

module connectivity2idenityPeering './02-connectivity/peeringModules/connectivity2idenityPeering.bicep' = if(!dryRun && deployConnectivity) {
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

module identity2connectiivtyPeering './02-connectivity/peeringModules/identity2connectivityPeering.bicep' = if(!dryRun && deployConnectivity) {
  name: 'spoke2ConnectivityHubPeering'
  scope: identityRG
  params: {
    connectivityVnetID: connectivityVnet.outputs.vnetID
    connectivityVnetName: connectivityVnetName
    identityVnetName: identityVnetName
    useRemoteGateways: useRemoteGateways
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
output kvName string = keyvault.outputs.keyVaultName
output EndVaultName string = vaultName
//output identityVnetName string = identityVnetName
//output vnetID string = connectivityVnetName.outputs.vnetID
//output subnetName string = addsVnet.outputs.subnetName
//output identityRGName string = identityRG.name
