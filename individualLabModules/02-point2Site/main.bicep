param prefix string
param rgLocation string
param regionShortCode string
param resourceTags object = {
  Environment: 'Dev'
  Project: 'Tutorial'
  Purpose: 'Hybrid Connectivity'
}
param addressSpacePrefix string = '10.0.0.0/24'
param vnetPrefix string = '10.0.0.0/25'
param gwPrefix string = '10.0.0.128/27'


var rgName = '${prefix}-${regionShortCode}-connectivity'
var vnetName = '${prefix}-${regionShortCode}-con-vnet'
var vngName = '${prefix}-${regionShortCode}-con-vng'
var pipName = '${prefix}-${regionShortCode}-con-pip'
var dnsName = '${prefix}-${regionShortCode}-con-pip'


targetScope = 'subscription'
resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' ={
  name: rgName
  location: rgLocation
  tags: resourceTags
}

module vnet './modules/network.bicep' = {
  name: 'vnet-deploy'
  scope: rg
  params: {
    vnetName: vnetName
    addressSpacePrefix: addressSpacePrefix
    vnetPrefix: vnetPrefix
    gwPrefix: gwPrefix
  }
}

module vng './modules/vng.bicep' = {
  name: 'vng-deploy'
  scope: rg
  params: {
    gwSubnetName: 'gatewaySubnet'
    vnetName: vnetName
    vngName: vngName
    pipName: pipName
  }
  dependsOn: [
    pip
  ]
}

module pip './modules/pip.bicep' = {
  name: 'pip-deploy'
  scope: rg
  params: {
    pipName: pipName
    dnsName: dnsName
  }
}

output connectivityHubVNetName string = '${prefix}-${regionShortCode}-con-vnet'
