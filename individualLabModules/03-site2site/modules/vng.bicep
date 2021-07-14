param vngName string
param vngRG string

resource vng 'Microsoft.Network/virtualNetworkGateways@2020-11-01' existing= {
  name: vngName
  scope: resourceGroup(vngRG)
}

output vngID string = vng.id
