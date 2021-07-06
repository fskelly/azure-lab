param vnet1RG string = 'flkelly-new-biceptesting1'
param vnet2RG string = 'flkelly-new-biceptesting2'

module vnet1 './vnet1.bicep' = {
  name: 'get-vnet1'
  scope: resourceGroup(vnet1RG)
  
}

module vnet2 './vnet2.bicep' = {
  name: 'get-vnet2'
  scope: resourceGroup(vnet2RG)
  
}

module vnet1Peering './peering1.bicep' = {
  name: 'vnet1-peering'
  scope: resourceGroup(vnet1RG)
  params: {
    vnet1Name: vnet1.outputs.vnet1name
    vnet2Name: vnet2.outputs.vnet2Name
    vnet2ID: vnet2.outputs.vnet2ID
  }
}

module vnet2Peering './peering2.bicep' = {
  name: 'vnet2-peering'
  scope: resourceGroup(vnet2RG)
  params: {
    vnet1Name: vnet1.outputs.vnet1name
    vnet2Name: vnet2.outputs.vnet2Name
    vnet1ID: vnet1.outputs.vnet1ID
  }
}

output vnet1ID string = vnet1.outputs.vnet1ID
output vnet2ID string = vnet2.outputs.vnet2ID
