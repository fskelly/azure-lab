targetScope = 'subscription'

param suffix string
param rgIdentityLocation string
param resourceTags object = {
  Environment: 'Dev'
  Project: 'Tutorial'
  Purpose: 'Identity'
  IaC: 'Bicep💪'
}
param subID string
param prefix string
param regionShortCode string
param addressSpacePrefix string = '10.0.0.0/24'
param vnetPrefix string = '10.0.0.0/25'
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
param psScriptLocation string = 'https://raw.githubusercontent.com/fskelly/azure-lab/test-branch/scripts/restart-vms/restart-vms.ps1'
param bastionSubnetIpPrefix string = '10.0.0.128/27'

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

var identityRGName = '${prefix}-${regionShortCode}-id-${suffix}'
var bastionHostName = '${prefix}-${regionShortCode}-adds-bastion'
var bastionSubnetName = 'AzureBastionSubnet'
var publicIpAddressName = '${bastionHostName}-pip'
var domainUserName = newForest == true ? '${split(domainFqdn,'.')[0]}\\${adminUsername}' : domainAdminUsername
var domainPassword = newForest == true ? localAdminPassword : domainAdminPassword
var domainSite = newForest == true ? 'Default-First-Site-Name' : site
var vnetName = '${prefix}-${regionShortCode}-adds-vnet'
var avSetName = '${prefix}-${regionShortCode}-adds-avset-1'
var managedIdentityName = '${prefix}-${regionShortCode}-adds-msi1'
var fullManagedIdentityID = '/subscriptions/${subID}/resourceGroups/${rgidentity.name}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${managedIdentityName}'
var domainAdminUsername = '${domainAdminUserName}@${domainFqdn}'

//Create Resource Groups
resource rgidentity 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: identityRGName
  location: rgIdentityLocation
  tags: resourceTags
}

module vnet './adModules/vnet.bicep' = {
  name: 'deploy-vnet'
  scope: rgidentity
  params: {
    vnetName: vnetName
    addressSpacePrefix: addressSpacePrefix
    vnetPrefix: vnetPrefix
    bastionSubnetName: bastionSubnetName
    bastionSubnetIpPrefix: bastionSubnetIpPrefix
    nsgName: 'ad-nsg'
  }
}

module managedIdentity './adModules/mi.bicep' = {
  name: 'deploy-managedIdentity'
  scope: rgidentity
  params: {
    managedIdentityName: managedIdentityName
  }
  
}

module avSet './adModules/avset.bicep' = {
  name: 'deploy-avset'
  scope: rgidentity
  params :{
    avSetName: avSetName
  }  
}

module publicIp './adModules/pip.bicep' = {
  name: 'deploy-pip'
  scope: rgidentity
  params: {
    location: rgIdentityLocation
    publicIpAddressName: publicIpAddressName

  }
}

module bastionHost './adModules/bastion.bicep' = {
  name: 'deploy-bastionHost'
  scope: rgidentity
  params: {
    bastionHostName: bastionHostName
    bastionSubnetID: vnet.outputs.bastionSubnetID
    location: rgIdentityLocation
    publicIpID: publicIp.outputs.publicIpID
  }
  dependsOn: [
    vnet
  ]
}

module nics './adModules/nics.bicep' = [for i in range(0, count): {
  name: '${vmNamePrefix}-${i + 1}-nic'
  scope: rgidentity
  params: {
    vnetID: vnet.outputs.vnetID
    //count: count
    i: i
    subnetName: vnet.outputs.subnetName
  }
}]

module nicsDns './adModules/nicDns.bicep' = {
  name: 'set-dns-nic'
  scope: rgidentity
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

module vmProperties './adModules/vmPropertiesBuilder.bicep' = {
  name: 'deploy-Properties-Builder'
  scope: rgidentity
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

module dcConfigurationBuild './adModules/configureDCs.bicep' = {
  name: 'deploy-dcs'
  scope: rgidentity
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
    managedIdentityName: managedIdentityName
  }
  
}

output username string = domainUserName
output logonName string = '${adminUsername}@${domainFqdn}'
output vnetName string = vnetName
output vnetID string = vnet.outputs.vnetID
output subnetName string = vnet.outputs.subnetName
output rgName string = rgidentity.name
