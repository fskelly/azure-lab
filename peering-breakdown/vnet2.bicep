param vnet2Name string = 'VNet2'
param vnet2RG string = 'flkelly-neu-connectivity'

resource vnet2 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnet2Name
}

output vnet2ID string = vnet2.id
output vnet2Name string = vnet2.name
