param spokeVnetName string = 'flkelly-neu-id-ss-vnet'
param spokeVnetNameRG string = 'flkelly-neu-identity'

resource spokeVnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: spokeVnetName
  scope: resourceGroup(spokeVnetNameRG)
}

output spokeVnetId string = spokeVnet.id
