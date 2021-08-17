targetScope = 'subscription'

//params
param prefix string
param subID string
param domainFqdn string
param domainAdminUserName string
@secure()
param domainAdminPassword string
@secure()
param localAdminPassword string
param identityRGLocation string
param localAdminUsername string
param baseTime string = utcNow('d-M-yyyy-HH-mm-ss')

//VARAIBLES
var identityRGName = '${prefix}-identity'

module rg './rg.bicep' = {
  name: 'deploy-rg-${baseTime}' 
  params: {
    //prefix: prefix
    identityRGLocation: identityRGLocation
    identityRGName:identityRGName
  }
}


module idShortCode '../tools/regionShortCode.bicep' = {
  name: 'get-id-shortcode-${baseTime}'
  scope: resourceGroup(identityRGName)
  params: {
    region: identityRGLocation
  }
  dependsOn: [
    rg
  ]
}

module networking './networking.bicep' = {
  name: 'deploy-networking-${baseTime}'
  scope: resourceGroup(identityRGName)
  params: {
    regionShortName: idShortCode.outputs.regionShortName
    prefix: prefix
    identityRGLocation: identityRGLocation
  }
  dependsOn: [
    rg
  ]
}

module bastionHost './ado/network/bastion.bicep' = {
  name: 'deploy-bastionHost-${baseTime}'
  scope: resourceGroup(identityRGName)
  params: {
    bastionHostName: networking.outputs.bastionHostName
    bastionSubnetID: networking.outputs.bastionSubnetID
    location: identityRGLocation
    publicIpID: networking.outputs.publicIpID
  }
  dependsOn: [
    networking
  ]
}

module dcs './dcs.bicep'= {
  name: 'deploy-dcs-${baseTime}'
  scope: resourceGroup(identityRGName)
  params: {
    domainAdminUserName: domainAdminUserName
    domainFqdn: domainFqdn
    domainAdminPassword: domainAdminPassword
    localAdminPassword: localAdminPassword
    adminUsername: localAdminUsername
    avSetID: networking.outputs.avSetID
    rgIdentityLocation: identityRGLocation
    addsVnetID: networking.outputs.vnetID
    addsSubnetName: networking.outputs.subnetName
    subID: subID
    rgIdentityName: identityRGName
    prefix: prefix
    regionShortCode: idShortCode.outputs.regionShortName
  }
  dependsOn: [
    networking
  ]
}
