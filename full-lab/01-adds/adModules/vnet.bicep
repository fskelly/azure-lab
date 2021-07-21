param resourceTags object = {
  Environment: 'Dev'
  Project: 'Tutorial'
  Purpose: 'Identity'
}

// Param Section
param vnetName string
param addressSpacePrefix string
param vnetPrefix string
param vnetLocation string = resourceGroup().location

param bastionSubnetName string
param bastionSubnetIpPrefix string

// VNET 
resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetName
  tags: resourceTags
  location: vnetLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressSpacePrefix
      ]
    }
    subnets: [
      {
        name: 'defaultSubnet'
        properties: {
          addressPrefix: vnetPrefix
        }
      }
      {
        name: bastionSubnetName
        properties: {
          addressPrefix: bastionSubnetIpPrefix
        }
      }
    ]
  }
}

output vnetID string = vnet.id
output subnetName string = vnet.properties.subnets[0].name
output bastionSubnetID string = vnet.properties.subnets[1].id
