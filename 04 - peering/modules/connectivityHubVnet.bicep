param connectivityHubVnetName string = 'flkelly-neu-con-vnet'
param connectivityHubVnetNameRG string = 'flkelly-neu-connectivity'

resource connectivityHubVnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: connectivityHubVnetName
  scope: resourceGroup(connectivityHubVnetNameRG)
}

output connectivityHubVnetID string = connectivityHubVnet.id
