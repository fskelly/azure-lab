param vnet1Name string = 'vnet1'
param vnet1RG string = 'flkelly-new-biceptesting1'

resource vnet1 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnet1Name
  scope: resourceGroup(vnet1RG)
}

output vnet1ID string = vnet1.id
output vnet1name string = vnet1.name
