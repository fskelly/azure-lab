param baseTime string = utcNow('d-M-yyyy-HH-mm-ss')
param count int = 2
param vmSize string = 'Standard_B2ms'
param ahub bool = false
param ntdsSizeGB int = 20
param sysVolSizeGB int = 20
param adminUsername string
@secure()
param localAdminPassword string
param timeZoneId string = 'Eastern Standard Time'
param dscConfigScript string = 'https://github.com/fskelly/azure-lab/releases/download/dsc-scripts/DomainControllerConfig.zip'
param domainFqdn string
param newForest bool = true
param domainAdminUserName string
@secure()
param domainAdminPassword string
param site string = 'Default-First-Site-Name'
param psScriptLocation string = 'https://raw.githubusercontent.com/fskelly/azure-lab/main/scripts/restart-vms/restart-vms.ps1'
param dnsServers array = [
  '168.63.129.16'
]
param avSetID string
param vmNamePrefix string = 'dc'
param rgIdentityLocation string
param addsVnetID string
param addsSubnetName string
param subID string
param rgIdentityName string
param prefix string
param regionShortCode string

var azRegions = [
  'eastus'
  'eastus2'
  'centralus'
  'southcentralus'
  'usgovvirginia'
  'westus2'
  'westus3'
]
var zones = [for i in range(0, count): contains(azRegions, rgIdentityLocation) ? [
  string(i == 0 || i == 3 || i == 6 ? 1 : i == 1 || i == 4 || i == 7 ? 2 : 3)
] : []]
var managedIdentityName = '${prefix}-${regionShortCode}-adds-msi1'
var fullManagedIdentityID = '/subscriptions/${subID}/resourceGroups/${rgIdentityName}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${managedIdentityName}'


module vmProperties './ado/dcs/vmPropertiesBuilder.bicep' = {
  name: 'deploy-Properties-Builder-${baseTime}'
  params: {
    ahub: ahub
    avsetId: avSetID
    count: count
    localAdminPassword: localAdminPassword
    localAdminUsername: adminUsername
    nics: [for i in range(0, count): {
      id: nicsDns.outputs.nicIds[i].id
    }]
    ntdsSizeGB: ntdsSizeGB
    sysVolSizeGB: sysVolSizeGB
    timeZoneId: timeZoneId
    vmNamePrefix: vmNamePrefix
    vmSize: vmSize
    zones: zones[0]
  }
}

module nics './ado/network/nics.bicep' = [for i in range(0, count): {
  name: 'ad-${i + 1}-nic'
  //name: 'ad-${i + 1}-nic-${baseTime}'
  params: {
    //vmNamePrefix: dcNamePrefix
    vnetID: addsVnetID
    i: i
    subnetName: addsSubnetName
    //shortCode: idShortCode.outputs.regionShortName
    //prefix: prefix
  }
}]


module nicsDns './ado/network/nicDns.bicep' = {
  //name: 'set-dns-nic-${baseTime}'
  name: 'set-dns-nic'
  params: {
    dnsServers: dnsServers
    nics: [for i in range(0, count): {
      name: nics[i].name
      ipConfigurations: nics[i].outputs.ipConfiguration
    }]
    count: count
    location: resourceGroup().location
  }
}

module dcConfigurationBuild './ado/dcs/configureDCs.bicep'= {
  name: 'deploy-dcs-${baseTime}'
  params: {
    domainFqdn: domainFqdn
    domainPassword: domainAdminPassword
    domainSite: site
    domainUserName: domainAdminUserName
    dscConfigScript: dscConfigScript
    fullManagedIdentityID: fullManagedIdentityID
    location: rgIdentityLocation
    newForest: newForest
    psScriptLocation: psScriptLocation
    vmNamePrefix: vmNamePrefix
    zones: zones
    dc1Properties: vmProperties.outputs.vmProperties[0]
    dc2Properties: vmProperties.outputs.vmProperties[1]
    //managedIdentityName: managedIdentityName
  }
  
}
