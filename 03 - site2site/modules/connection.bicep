param vngName string
param lngName string
@secure()
param sharedKey string
param connectionName string

resource vpnVnetConnection 'Microsoft.Network/connections@2020-11-01' = {
  name: connectionName
  location: resourceGroup().location
  properties: {
    virtualNetworkGateway1: {
      id: resourceId('Microsoft.Network/virtualNetworkGateways', vngName)
      properties:{}
    }
    localNetworkGateway2: {
      id: resourceId('Microsoft.Network/localNetworkGateways', lngName)
      properties:{}
    }
    connectionType: 'IPsec'
    routingWeight: 0
    sharedKey: sharedKey
  }
}
