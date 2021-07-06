param vnet2Name string = 'vnet2'
param vnet2RG string = 'flkelly-new-biceptesting2'

resource vnet2 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnet2Name
  scope: resourceGroup(vnet2RG)
}

output vnet2ID string = vnet2.id
output vnet2Name string = vnet2.name
