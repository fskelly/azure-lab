param lngName string
param onPremCIDR string
param gateway string

param resourceTags object = {
  Environment: 'Dev'
  Project: 'Tutorial'
  Purpose: 'Hybrid Connectivity'
}

resource localNetworkGateway 'Microsoft.Network/localNetworkGateways@2019-11-01' = {
  name: lngName
  tags: resourceTags
  location: resourceGroup().location
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: [
        onPremCIDR
      ]
    }
    gatewayIpAddress: gateway
  }
}
