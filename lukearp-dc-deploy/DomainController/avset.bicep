param avSetName string

resource availabilitySet 'Microsoft.Compute/availabilitySets@2020-12-01' = {
  name: avSetName
  location: resourceGroup().location
  sku: {
    name: 'Aligned'
  }
}

output avSetID string = availabilitySet.id
