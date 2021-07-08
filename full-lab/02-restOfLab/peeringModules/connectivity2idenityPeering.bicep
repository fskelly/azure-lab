param connectivityVnetName string
param identityVnetName string
param identityVnetID string

resource connectivityHub2Spokepeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = {
  name: '${connectivityVnetName}/${connectivityVnetName}-${identityVnetName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: identityVnetID
    }
  }
}
