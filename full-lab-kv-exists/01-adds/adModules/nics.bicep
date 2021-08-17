param resourceTags object = {
  Environment: 'Dev'
  Project: 'Tutorial'
  Purpose: 'Identity'
}

//param count int
//param vmNamePrefix string
param vnetID string
param subnetName string
param i int
//var nicName = '${prefix}-${shortCode}-ad-vm'

resource nics 'Microsoft.Network/networkInterfaces@2020-11-01' = /*[for i in range(0, count): */ {
  name: 'ad-${i + 1}-nic'
  tags: resourceTags
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
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
