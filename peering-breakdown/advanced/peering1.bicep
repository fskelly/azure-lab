param vnet1Name string
param vnet2Name string
param vnet1RG string = 'flkelly-neu-biceptesting1'
param vnet2ID string

resource VnetPeering1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-06-01' = {
  name: '${vnet1Name}/${vnet1Name}-${vnet2Name}'
  //scope: resourceGroup(vnet1RG)
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vnet2ID
    }
  }
}
