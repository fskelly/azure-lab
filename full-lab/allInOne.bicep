targetScope = 'subscription'

param suffix string = 'blah1'
param subID string = '949ef534-07f5-4138-8b79-aae16a71310c'
param prefix string = 'flkelly'
param regionShortCode string

// Identity Params
param identiyResourceTags object = {
  Environment: 'Dev'
  Project: 'Tutorial'
  Purpose: 'Identity'
  IaC: 'Bicep💪'
}
param rgIdentityLocation string
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
param psScriptLocation string = 'https://raw.githubusercontent.com/fskelly/azure-lab/test-branch/scripts/restart-vms/restart-vms.ps1'
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
//param identityVnetRG string
//param identityVnetName string
param deploySiteToSite bool = true

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
var identityRGName = '${prefix}-${regionShortCode}-id-${suffix}'
var bastionHostName = '${prefix}-${regionShortCode}-adds-bastion'
var bastionSubnetName = 'AzureBastionSubnet'
var publicIpAddressName = '${bastionHostName}-pip'
var domainUserName = newForest == true ? '${split(domainFqdn,'.')[0]}\\${adminUsername}' : domainAdminUsername
var domainPassword = newForest == true ? localAdminPassword : domainAdminPassword
var domainSite = newForest == true ? 'Default-First-Site-Name' : site
var identityVnetName = '${prefix}-${regionShortCode}-adds-vnet'
var avSetName = '${prefix}-${regionShortCode}-adds-avset-1'
var managedIdentityName = '${prefix}-${regionShortCode}-adds-msi1'
var fullManagedIdentityID = '/subscriptions/${subID}/resourceGroups/${identityRG.name}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${managedIdentityName}'
var domainAdminUsername = '${domainAdminUserName}@${domainFqdn}'

// Connectivity Variables

var connectivityRGName = '${prefix}-${regionShortCode}-connectivity-${suffix}'
var connectivityVnetName = '${prefix}-${regionShortCode}-con-vnet'
var vngName = '${prefix}-${regionShortCode}-con-vng'
//var pipName = '${prefix}-${regionShortCode}-con-pip'
var dnsName = substring('${prefix}-${regionShortCode}-pip-${uniqueString(connectivityRG.id)}',0, 29)
var lngName = '${prefix}-${regionShortCode}-con-lng'
var connectivytPipName = substring('${prefix}-${regionShortCode}-pip-${uniqueString(connectivityRG.id)}',0, 29)


//Create Resource Groups
resource identityRG 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: identityRGName
  location: rgIdentityLocation
  tags: identiyResourceTags
}

resource connectivityRG 'Microsoft.Resources/resourceGroups@2020-06-01' ={
  name: connectivityRGName
  location: connectivityRGLocation
  tags: connectivityResourceTags
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
  }
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

/* module connectivityVnet './peeringModules/connectivityVnet.bicep' = {
  name: 'get-connectivity-vnet'
  scope: resourceGroup(rgName)
  params: {

  }
} */

/* module identityVnet './02-connectivity/peeringModules/identityVnet.bicep' = {
  name: 'get-identity-vnet'
  scope: resourceGroup(identityVnetRG)
  params: {
    identityVnetName: identityVnetName
    identityVnetRG: identityVnetRG
  }
} */

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
output pipName string = connectivytPipName
//output vngPIP string = pip.outputs.pipIP
//output sharedKey string = sharedKey
output username string = domainUserName
output logonName string = '${adminUsername}@${domainFqdn}'
output identityVnetName string = identityVnetName
//output vnetID string = connectivityVnetName.outputs.vnetID
output subnetName string = addsVnet.outputs.subnetName
output identityRGName string = identityRG.name
