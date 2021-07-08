param connectivityHubVnetName string
param connectivityHubVnetNameRG string

resource connectivityHubVnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: connectivityHubVnetName
  scope: resourceGroup(connectivityHubVnetNameRG)
}

output connectivityHubVnetID string = connectivityHubVnet.id
