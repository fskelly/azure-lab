param bastionHostName string
param location string
param bastionSubnetID string
param publicIpID string

param resourceTags object = {
  Environment: 'Dev'
  Project: 'Tutorial'
  Purpose: 'Identity'
  IaC: 'Bicep💪'
}

resource bastionHost 'Microsoft.Network/bastionHosts@2020-05-01' = {
  name: bastionHostName
  tags: resourceTags
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: bastionSubnetID
          }
          publicIPAddress: {
            id: publicIpID
          }
        }
      }
    ]
  }
}
