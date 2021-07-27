param prefix string
param suffix string
param connectivityRGLocation string
param regionShortCode string
param resourceTags object = {
  Environment: 'Dev'
  Project: 'Tutorial'
  Purpose: 'Hybrid Connectivity'
  IaC: 'Bicep💪'
}
param addressSpacePrefix string = '10.1.0.0/24'
param vnetPrefix string = '10.1.0.0/25'
param gwPrefix string = '10.1.0.128/27'
param onPremCIDR string = '192.168.1.0/24'
param gwIP string
@secure()
param sharedKey string
param identityVnetRG string
param identityVnetName string
param deploySiteToSite bool = true

param skuTier string = 'VpnGw1AZ'
param skuName string = 'VpnGw1AZ'

var connectivityRGName = '${prefix}-${regionShortCode}-connectivity-${suffix}'
var vnetName = '${prefix}-${regionShortCode}-con-vnet'
var vngName = '${prefix}-${regionShortCode}-con-vng'
//var pipName = '${prefix}-${regionShortCode}-con-pip'
var dnsName = substring('${prefix}-${regionShortCode}-pip-${uniqueString(connectivityRG.id)}',0, 29)
var lngName = '${prefix}-${regionShortCode}-con-lng'
var pipName = substring('${prefix}-${regionShortCode}-pip-${uniqueString(connectivityRG.id)}',0, 29)

targetScope = 'subscription'
resource connectivityRG 'Microsoft.Resources/resourceGroups@2020-06-01' ={
  name: connectivityRGName
  location: connectivityRGLocation
  tags: resourceTags
}

module vnet './p2sModules/network.bicep' = {
  name: 'vnet-deploy'
  scope: connectivityRG
  params: {
    vnetName: vnetName
    addressSpacePrefix: addressSpacePrefix
    vnetPrefix: vnetPrefix
    gwPrefix: gwPrefix
  }
  dependsOn: [
    connectivityRG
  ]
}

module vng './p2sModules/vng.bicep' = {
  name: 'vng-deploy'
  scope: connectivityRG
  params: {
    gwSubnetName: 'gatewaySubnet'
    vnetName: vnetName
    vngName: vngName
    pipName: pipName
    skuName: skuName
    skuTier: skuTier
  }
  dependsOn: [
    pip
  ]
}

module pip './p2sModules/pip.bicep' = {
  name: 'pip-deploy'
  scope: connectivityRG
  params: {
    pipName: pipName
    dnsName: dnsName
  }
}

module lng './s2sModules/lng.bicep' = if (deploySiteToSite == true){
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

module connection 's2sModules/connection.bicep' = if (deploySiteToSite == true){
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

module identityVnet './peeringModules/identityVnet.bicep' = {
  name: 'get-identity-vnet'
  scope: resourceGroup(identityVnetRG)
  params: {
    identityVnetName: identityVnetName
    identityVnetRG: identityVnetRG
  }
}

module connectivity2idenityPeering './peeringModules/connectivity2idenityPeering.bicep' = {
  name: 'deploy-connectivity2identitypeering'
  scope: connectivityRG
  params: {
    connectivityVnetName: vnetName
    identityVnetID: identityVnet.outputs.idenityVnetId
    identityVnetName: identityVnetName
  }
  dependsOn:[
    vng
  ]
} 

module identity2connectiivtyPeering './peeringModules/identity2connectivityPeering.bicep' = {
  name: 'spoke2ConnectivityHubPeering'
  scope: resourceGroup(identityVnetRG)
  params: {
    connectivityVnetID: vnet.outputs.vnetID
    connectivityVnetName: vnetName
    identityVnetName: identityVnetName
  }
  dependsOn:[
    vng
  ]
}

//output spokeVnetID string = spokeVnet.outputs.spokeVnetId
//output connectivityHubVnetID string = hubVnet.outputs.connectivityHubVnetID
output pipName string = pipName
//output vngPIP string = pip.outputs.pipIP
//output sharedKey string = sharedKey
