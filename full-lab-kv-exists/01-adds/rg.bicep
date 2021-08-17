// General Params
targetScope = 'subscription'

//PARAMETERS
//param prefix string
param identityResourceTags object = {
  Environment: 'Dev'
  Project: 'Tutorial'
  Purpose: 'Identity'
  IaC: 'Bicep💪'
}
param identityRGLocation string

//VARIABLES
param identityRGName string

//Create Resource Groups

resource identityRG 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: identityRGName
  location: identityRGLocation
  tags: identityResourceTags
}

/* module idShortCode '../tools/regionShortCode.bicep' = {
  name: 'get-id-shortcode'
  scope: identityRG
  params: {
    region: identityRGLocation
  }
} */

output identityRGName string = identityRG.name
//output regionShortName string = idShortCode.outputs.regionShortName
