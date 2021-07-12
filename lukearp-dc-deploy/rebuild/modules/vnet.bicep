// Param Section
param vnetName string
param addressSpacePrefix string
param vnetPrefix string
param vnetLocation string = resourceGroup().location

param resourceTags object = {
  Environment: 'Dev'
  Project: 'Tutorial'
  Purpose: 'Hybrid Connectivity'
}

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
    ]
  }
}

output vnetID string = vnet.id
output subnetName string = vnet.properties.subnets[0].name
