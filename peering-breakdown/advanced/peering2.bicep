param vnet2Name string
param vnet1Name string
param vnet1ID string

resource VnetPeering2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-06-01' = {
  name: '${vnet2Name}/${vnet2Name}-${vnet1Name}'
  //scope: resourceGroup(vnet1RG)
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vnet1ID
    }
  }
}
