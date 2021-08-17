param resourceTags object = {
  Environment: 'Dev'
  Project: 'Tutorial'
  Purpose: 'Identity'
}

param avSetName string

resource availabilitySet 'Microsoft.Compute/availabilitySets@2020-12-01' = {
  name: avSetName
  tags: resourceTags
  location: resourceGroup().location
  sku: {
    name: 'Aligned'
  }
  properties: {
    platformUpdateDomainCount: 2
    platformFaultDomainCount: 2
  }
}

output avSetID string = availabilitySet.id
