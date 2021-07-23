param identityVnetName string
param identityVnetRG string

resource identityVnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: identityVnetName
  scope: resourceGroup(identityVnetRG)
}

output idenityVnetId string = identityVnet.id
