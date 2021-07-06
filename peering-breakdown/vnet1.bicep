param vnet1Name string = 'VNet1'
param vnet1RG string = 'flkelly-neu-connectivity'

resource vnet1 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnet1Name
}

output vnet1ID string = vnet1.id
output vnet1name string = vnet1.name
