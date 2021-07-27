param resourceTags object = {
  Environment: 'Dev'
  Project: 'Tutorial'
  Purpose: 'Identity'
}

//param count int
param vmNamePrefix string
param vnetID string
param subnetName string
param i int
param dryRun bool

resource nics 'Microsoft.Network/networkInterfaces@2020-11-01' = if(!dryRun) /*[for i in range(0, count): */ {
  name: '${vmNamePrefix}-${i + 1}-nic'
  tags: resourceTags
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'dc'
        properties: {
          primary: true
          subnet: {
            id: '${vnetID}/subnets/${subnetName}'
          }
        }
      }
    ]
  }
}

output ipConfiguration array = nics.properties.ipConfigurations
