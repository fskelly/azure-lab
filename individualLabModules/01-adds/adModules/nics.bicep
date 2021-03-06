param count int
param vmNamePrefix string
param vnetID string
param subnetName string

resource nics 'Microsoft.Network/networkInterfaces@2020-11-01' = [for i in range(0, count): {
  name: '${vmNamePrefix}-${i + 1}-nic'
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
}]
