param connectivityHubVnetName string = 'flkelly-neu-con-vnet'
param spokeVnetName string
param spokeVnetID string

resource connectivityHub2Spokepeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = {
  name: '${connectivityHubVnetName}/${connectivityHubVnetName}-${spokeVnetName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: spokeVnetID
    }
  }
}
