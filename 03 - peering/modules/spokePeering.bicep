param spokeVnetName string = 'flkelly-neu-id-ss-vnet'
param connectivityHubVnetName string
param connectivityHubVnetID string

resource spoke2connectivityHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = {
  name: '${spokeVnetName}/${spokeVnetName}-${connectivityHubVnetName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: true
    remoteVirtualNetwork: {
      id: connectivityHubVnetID
    }
  }
}
