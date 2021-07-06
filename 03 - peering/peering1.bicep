param connectivityHubVnetNameRG string = 'flkelly-neu-connectivity'
param spokeVnetNameRG string = 'flkelly-neu-identity'
param connectivityHubVnetName string = 'flkelly-neu-con-vnet'
param spokeVnetName string = 'flkelly-neu-id-ss-vnet'

targetScope = 'subscription'

module hubVnet './modules/connectivityHubVnet.bicep' = {
  name: 'hubVnet'
  scope: resourceGroup(connectivityHubVnetNameRG)
  params: {

  }
}

module spokeVnet 'modules/spokeVnet.bicep' = {
  name: 'spokeVnet'
  scope: resourceGroup(spokeVnetNameRG)
  params: {

  }
}

module connectivityHub2Spokepeering './modules/connectivityHubPeering.bicep' = {
  name: 'connectivityHub2Spokepeering'
  scope: resourceGroup(connectivityHubVnetNameRG)
  params: {
    spokeVnetID: spokeVnet.outputs.spokeVnetId
    spokeVnetName: spokeVnetName
  }
}

module spoke2HubPeering 'modules/spokePeering.bicep' = {
  name: 'spoke2ConnectivityHubPeering'
  scope: resourceGroup(spokeVnetNameRG)
  params: {
    connectivityHubVnetID: hubVnet.outputs.connectivityHubVnetID
    connectivityHubVnetName: connectivityHubVnetName
  }
}


