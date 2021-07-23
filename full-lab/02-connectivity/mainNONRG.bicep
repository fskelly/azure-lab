param prefix string
//param rgLocation string
param regionShortCode string
/* param resourceTags object = {
  Environment: 'Dev'
  Project: 'Tutorial'
  Purpose: 'Hybrid Connectivity'
} */
param addressSpacePrefix string = '10.0.0.0/24'
param vnetPrefix string = '10.0.0.0/25'
param gwPrefix string = '10.0.0.128/27'
param onPremCIDR string = '192.168.1.0/24'
param gwIP string
@secure()
param sharedKey string
param identityVnetRG string
param identityVnetName string

//var rgName = '${prefix}-${regionShortCode}-connectivity-1'
var vnetName = '${prefix}-${regionShortCode}-con-vnet'
var vngName = '${prefix}-${regionShortCode}-con-vng'
//var pipName = '${prefix}-${regionShortCode}-con-pip'
var dnsName = substring('${prefix}-${regionShortCode}-pip-${uniqueString(resourceGroup().id)}',0, 29)
var lngName = '${prefix}-${regionShortCode}-con-lng'
var pipName = substring('${prefix}-${regionShortCode}-pip-${uniqueString(resourceGroup().id)}',0, 29)

/* targetScope = 'subscription'
resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' ={
  name: rgName
  location: rgLocation
  tags: resourceTags
} */

module vnet './p2sModules/network.bicep' = {
  name: 'vnet-deploy'
  params: {
    vnetName: vnetName
    addressSpacePrefix: addressSpacePrefix
    vnetPrefix: vnetPrefix
    gwPrefix: gwPrefix
  }
}

module vng './p2sModules/vng.bicep' = {
  name: 'vng-deploy'
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

module pip './p2sModules/pip.bicep' = {
  name: 'pip-deploy'
  params: {
    pipName: pipName
    dnsName: dnsName
  }
}

module lng './s2sModules/lng.bicep' = {
  name: 'lng-deploy'
//  scope: resourceGroup(rgName)
  params: {
    lngName: lngName
    onPremCIDR: onPremCIDR
    gateway: gwIP
  }
  dependsOn: [
    pip
  ]
}

module connection 's2sModules/connection.bicep' = {
  name: 'deploy-connection'
//  scope: resourceGroup(rgName)
  params: {
    connectionName: 'azure-to-home'
    lngName: lngName
    vngName: vngName
    sharedKey: sharedKey
  }
  dependsOn: [
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
//  scope: resourceGroup(rgName)
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
