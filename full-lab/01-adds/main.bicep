param resourceTags object = {
  Environment: 'Dev'
  Project: 'Tutorial'
  Purpose: 'Identity'
  IaC: 'Bicep💪'
}

param subID string
param prefix string
param regionShortCode string
param rgName string

param addressSpacePrefix string = '10.0.0.0/24'
param vnetPrefix string = '10.0.0.0/25'

param vmNamePrefix string = 'dc'
param dnsServers array = [
  '168.63.129.16'
]
param location string = resourceGroup().location
param count int = 2

param vmSize string = 'Standard_B2ms'
param ahub bool = false
param ntdsSizeGB int = 20
param sysVolSizeGB int = 20
param localAdminUsername string
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

param psScriptLocation string = 'https://raw.githubusercontent.com/fskelly/azure-lab/test-branch/scripts/restart-vms/restart-vms.ps1'

var azRegions = [
  'eastus'
  'eastus2'
  'centralus'
  'southcentralus'
  'usgovvirginia'
  'westus2'
  'westus3'
]
var zones = [for i in range(0, count): contains(azRegions, location) ? [
  string(i == 0 || i == 3 || i == 6 ? 1 : i == 1 || i == 4 || i == 7 ? 2 : 3)
] : []]


param bastionSubnetIpPrefix string = '10.0.0.128/27'
var bastionHostName = '${prefix}-${regionShortCode}-adds-bastion'
var bastionSubnetName = 'AzureBastionSubnet'
var publicIpAddressName = '${bastionHostName}-pip'

var domainUserName = newForest == true ? '${split(domainFqdn,'.')[0]}\\${localAdminUsername}' : domainAdminUsername
var domainPassword = newForest == true ? localAdminPassword : domainAdminPassword
var domainSite = newForest == true ? 'Default-First-Site-Name' : site

var vnetName = '${prefix}-${regionShortCode}-adds-vnet'
var avSetName = '${prefix}-${regionShortCode}-adds-avset-1'
var managedIdentityName = '${prefix}-${regionShortCode}-adds-msi1'
var fullManagedIdentityID = '/subscriptions/${subID}/resourceGroups/${rgName}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${managedIdentityName}'
var domainAdminUsername = '${domainAdminUserName}@${domainFqdn}'



module vnet './adModules/vnet.bicep' = {
  name: 'deploy-vnet'
  params: {
    vnetName: vnetName
    addressSpacePrefix: addressSpacePrefix
    vnetPrefix: vnetPrefix
    bastionSubnetName: bastionSubnetName
    bastionSubnetIpPrefix: bastionSubnetIpPrefix
  }
}

module managedIdentity './adModules/mi.bicep' = {
  name: 'deploy-managedIdentity'
  params: {
    managedIdentityName: managedIdentityName
  }
  
}

module avSet './adModules/avset.bicep' = {
  name: 'deploy-avset'
  params :{
    avSetName: avSetName
  }  
}

/* resource publicIp 'Microsoft.Network/publicIpAddresses@2020-05-01' = {
  name: publicIpAddressName
  tags: resourceTags
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
} */

module publicIp './adModules/pip.bicep' = {
  name: 'deploy-pip'
  params: {
    location: resourceGroup().location
    publicIpAddressName: publicIpAddressName

  }
}

/* resource bastionHost 'Microsoft.Network/bastionHosts@2020-05-01' = {
  name: bastionHostName
  tags: resourceTags
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: vnet.outputs.bastionSubnetID
          }
          publicIPAddress: {
            id: publicIp.outputs.publicIpID
          }
        }
      }
    ]
  }
  dependsOn: [
    vnet
  ]
} */

module bastionHost './adModules/bastion.bicep' = {
  name: 'deploy-bastionHost'
  params: {
    bastionHostName: bastionHostName
    bastionSubnetID: vnet.outputs.bastionSubnetID
    location: resourceGroup().location
    publicIpID: publicIp.outputs.publicIpID
  }
  dependsOn: [
    vnet
  ]
}
/* resource nics 'Microsoft.Network/networkInterfaces@2020-11-01' = [for i in range(0, count): {
  name: '${vmNamePrefix}-${i + 1}-nic'
  tags: resourceTags
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'dc'
        properties: {
          primary: true
          subnet: {
            id: '${vnet.outputs.vnetID}/subnets/${vnet.outputs.subnetName}'
          }
        }
      }
    ]
  }
}] */

module nics './adModules/nics.bicep' = [for i in range(0, count): {
  name: '${vmNamePrefix}-${i + 1}-nic'
  params: {
    vmNamePrefix: vmNamePrefix
    vnetID: vnet.outputs.vnetID
    //count: count
    i: i
    subnetName: vnet.outputs.subnetName
    
  }
}]

module nicsDns './adModules/nicDns.bicep' = {
  name: 'set-dns-nic'
  params: {
    dnsServers: dnsServers
    nics: [for i in range(0, count): {
      name: nics[i].name
      ipConfigurations: nics[i].outputs.ipConfiguration
    }]
    count: count
    location: location
  }
}

module vmProperties './adModules/vmPropertiesBuilder.bicep' = {
  name: 'deploy-Properties-Builder'
  params: {
    ahub: ahub
    avsetId: avSet.outputs.avSetID
    count: count
    localAdminPassword: localAdminPassword
    localAdminUsername: localAdminUsername
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

module dcConfigurationBuild './adModules/configureDCs.bicep' = {
  name: 'deploy-dcs'
  params: {
    domainFqdn: domainFqdn
    domainPassword: domainPassword
    domainSite: domainSite
    domainUserName: domainUserName
    dscConfigScript: dscConfigScript
    fullManagedIdentityID: fullManagedIdentityID
    location: resourceGroup().location
    newForest: newForest
    psScriptLocation: psScriptLocation
    vmNamePrefix: vmNamePrefix
    zones: zones
    dc1Properties: vmProperties.outputs.vmProperties[0]
    dc2Properties: vmProperties.outputs.vmProperties[1]
  }
  
}

/* resource dc1 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: '${vmNamePrefix}-1'
  tags: resourceTags
  location: location
  zones: zones[0]
  properties: vmProperties.outputs.vmProperties[0]
} */

/* resource dc1Extension 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${vmNamePrefix}-1/DC-Creation'
  tags: resourceTags
  location: location
  dependsOn: [
    dc1
  ]
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.73'
    autoUpgradeMinorVersion: true
    settings: {
      modulesUrl: dscConfigScript
      configurationFunction: 'DomainControllerConfig.ps1\\DomainControllerConfig'
      properties: [
        {
          Name: 'creds'
          Value: {
            UserName: domainUserName
            Password: 'PrivateSettingsRef:domainPassword'
          }
          TypeName: 'System.Management.Automation.PSCredential'
        }
        {
          Name: 'domain'
          Value: domainFqdn
          TypeName: 'System.String'
        }
        {
          Name: 'site'
          Value: domainSite
          TypeName: 'System.String'
        }
        {
          Name: 'newForest'
          Value: newForest
          TypeName: 'System.Boolean'
        }
      ]
    }
    protectedSettings: {
      Items: {
        domainPassword: domainPassword
      }
    }
  }
} 

resource rebootDc1 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  kind: 'AzurePowerShell'
  tags: resourceTags
  location: location
  name: '${dc1.name}-rebootDc'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${fullManagedIdentityID}':{}

    }  
  } 
  properties: {
    arguments: '${array(dc1.name)} ${resourceGroup().name} ${subscription().subscriptionId}'
    primaryScriptUri: psScriptLocation 
    azPowerShellVersion: '5.9'
    retentionInterval: 'PT1H'    
  } 
  dependsOn: [
    dc1Extension 
  ]    
} */
/* module dc1 './adModules/dc1.bicep' = {
  name: 'deploy-dc1'
  params: {
    domainFqdn: domainFqdn
    domainPassword: domainPassword
    domainSite: domainSite
    domainUserName: domainUserName
    dscConfigScript: dscConfigScript
    fullManagedIdentityID: fullManagedIdentityID
    location: resourceGroup().location
    newForest: newForest
    psScriptLocation: psScriptLocation
    vmNamePrefix: vmNamePrefix
    vmProperties: vmProperties.outputs.vmProperties[0]
    zones: zones[0]
  }
  
}

module dc2 './adModules/otherDc.bicep' = {
  name: 'deploy-dc2'
  params: {
    domainFqdn: domainFqdn
    domainPassword: domainPassword
    domainSite: domainSite
    domainUserName: domainUserName
    dscConfigScript: dscConfigScript
    fullManagedIdentityID: fullManagedIdentityID
    location: resourceGroup().location
    newForest: newForest
    psScriptLocation: psScriptLocation
    vmNamePrefix: vmNamePrefix
    vmProperties: vmProperties.outputs.vmProperties[1]
    zones: zones[0]
  }
  
} */

/* resource otherDc 'Microsoft.Compute/virtualMachines@2020-12-01' = if(count > 1) {
  dependsOn: [
    rebootDc1
  ]
  tags: resourceTags
  location: location
  name: '${vmNamePrefix}-2'
  zones: zones[1]
  properties: vmProperties.outputs.vmProperties[1]
}

resource otherDcExtension 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = if(count > 1){
  name: '${vmNamePrefix}-2/DC-Creation'
  location: location
  tags: resourceTags
  dependsOn: [
    otherDc
  ]
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.73'
    autoUpgradeMinorVersion: true
    settings: {
      modulesUrl: dscConfigScript
      configurationFunction: 'DomainControllerConfig.ps1\\DomainControllerConfig'
      properties: [
        {
          Name: 'creds'
          Value: {
            UserName: domainUserName
            Password: 'PrivateSettingsRef:domainPassword'
          }
          TypeName: 'System.Management.Automation.PSCredential'
        }
        {
          Name: 'domain'
          Value: domainFqdn
          TypeName: 'System.String'
        }
        {
          Name: 'site'
          Value: domainSite
          TypeName: 'System.String'
        }
        {
          Name: 'newForest'
          Value: false
          TypeName: 'System.Boolean'
        }
      ]
    }
    protectedSettings: {
      Items: {
        domainPassword: domainPassword
      }
    } 
  }
}

resource rebootOtherVms 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  kind: 'AzurePowerShell'
  tags: resourceTags
  location: location
  name: '${otherDc.name}-rebootOtherVms'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${fullManagedIdentityID}':{}
    }  
  } 
  properties: {
    arguments: '${array(otherDc.name)} ${resourceGroup().name} ${subscription().subscriptionId}'
    primaryScriptUri: psScriptLocation 
    azPowerShellVersion: '5.9'
    retentionInterval: 'PT1H'    
  } 
  dependsOn: [
    otherDcExtension     
  ]    
}
 */
output username string = domainAdminUsername
output vnetName string = vnetName
output vnetID string = vnet.outputs.vnetID
output subnetName string = vnet.outputs.subnetName
output rgName string = resourceGroup().name
