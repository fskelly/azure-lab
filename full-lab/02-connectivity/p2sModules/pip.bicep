param pipName string
param dnsName string
param skuName string

param resourceTags object = {
  Environment: 'Dev'
  Project: 'Tutorial'
  Purpose: 'Hybrid Connectivity'
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: pipName
  sku: {
    name: skuName
  }
  tags: resourceTags
  location: resourceGroup().location
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: dnsName
    }
  }
}

output pipID string = publicIPAddress.id
//output pipIP string = publicIPAddress.properties.ipAddress
