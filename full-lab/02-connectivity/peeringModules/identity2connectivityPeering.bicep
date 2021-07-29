param identityVnetName string
param connectivityVnetName string
param connectivityVnetID string
param useRemoteGateways bool

resource spoke2connectivityHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = {
  name: '${identityVnetName}/${identityVnetName}-${connectivityVnetName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: useRemoteGateways
    remoteVirtualNetwork: {
      id: connectivityVnetID
    }
  }
}
