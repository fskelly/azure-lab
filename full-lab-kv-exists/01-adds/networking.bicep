//PARAMS
param baseTime string = utcNow('d-M-yyyy-HH-mm-ss')
param identityRGLocation string
param identityAddressSpacePrefix string = '10.0.0.0/24'
param identityVnetPrefix string = '10.0.0.0/25'
param prefix string
param regionShortName string
param bastionSubnetIpPrefix string = '10.0.0.128/27'

//VARIABLES

var avSetName = '${prefix}-${regionShortName}-adds-avset-1'
var bastionHostName = '${prefix}-${regionShortName}-adds-bastion'
var bastionSubnetName = 'AzureBastionSubnet'
var publicIpAddressName = '${bastionHostName}-pip'
var identityRGName = '${prefix}-identity'
var identityVnetName = '${prefix}-${regionShortName}-adds-vnet'


module addsVnet './ado/network/vnet.bicep' = {
  name: 'deploy-vnet-${baseTime}'
  scope: resourceGroup(identityRGName)
  params: {
    vnetName: identityVnetName
    addressSpacePrefix: identityAddressSpacePrefix
    vnetPrefix: identityVnetPrefix
    bastionSubnetName: bastionSubnetName
    bastionSubnetIpPrefix: bastionSubnetIpPrefix
    nsgName: 'adds-nsg'
  }
}

module avSet './ado/network/avset.bicep' =  {
  name: 'deploy-avset-${baseTime}'
  scope: resourceGroup(identityRGName)
  params :{
    avSetName: avSetName
  }  
}

module bastionPublicIp './ado/network/pip.bicep' = {
  name: 'deploy-pip-${baseTime}'
  scope: resourceGroup(identityRGName)
  params: {
    location: identityRGLocation
    publicIpAddressName: publicIpAddressName

  }
}

output vnetID string = addsVnet.outputs.vnetID
output subnetName string = addsVnet.outputs.subnetName
output bastionSubnetID string = addsVnet.outputs.bastionSubnetID
output avSetID string = avSet.outputs.avSetID
output bastionHostName string = bastionHostName
output publicIpID string = bastionPublicIp.outputs.publicIpID
