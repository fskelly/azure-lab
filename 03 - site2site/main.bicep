param prefix string
param regionShortCode string
param connectivityRGName string = 'flkelly-neu-connectivity'
param onPremCIDR string = '192.168.1.0/24'
param gwIP string
@secure()
param sharedKey string
var lngName = '${prefix}-${regionShortCode}-con-lng'
var vngName = '${prefix}-${regionShortCode}-con-vng'


module lng 'modules/lng.bicep' = {
  name: 'lng-deploy'
  scope: resourceGroup(connectivityRGName)
  params: {
    lngName: lngName
    onPremCIDR: onPremCIDR
    gateway: gwIP
  }
}

module vng 'modules/vng.bicep' ={
  name: 'get-vng'
  scope: resourceGroup(connectivityRGName)
  params: {
    vngName: vngName
    vngRG: connectivityRGName
  }
}

module connection 'modules/connection.bicep' = {
  name: 'deploy-connection'
  scope: resourceGroup(connectivityRGName)
  params: {
    connectionName: 'azure-to-home'
    lngName: lngName
    vngName: vngName
    sharedKey: sharedKey
  }
  
}
