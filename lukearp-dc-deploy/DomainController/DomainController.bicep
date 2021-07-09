@maxLength(13)
param vmNamePrefix string = 'dc'
param location string = resourceGroup().location
param vmSize string = 'Standard_B2ms'
param ahub bool = false
@maxValue(2)
param count int = 2
//param vnetId string = '/subscriptions/949ef534-07f5-4138-8b79-aae16a71310c/resourceGroups/flkelly-neu-identity-2/providers/Microsoft.Network/virtualNetworks/vnet1'
//param subnetName string = 'default'
param ntdsSizeGB int = 20
param sysVolSizeGB int = 20
param localAdminUsername string = 'azure_ad_groot'
@secure()
param localAdminPassword string
param domainFqdn string = 'fskelly.com'
param newForest bool = true
param domainAdminUsername string = 'azure_ad_groot@fskelly.com'
@secure()
param domainAdminPassword string
param site string = 'Default-First-Site-Name'
param dnsServers array = [
  '168.63.129.16'
]
param dscConfigScript string = 'https://github.com/lukearp/Azure-IAC-Bicep/releases/download/DSC/DomainControllerConfig.zip'
param timeZoneId string = 'Eastern Standard Time'
param managedIdentityId string = '/subscriptions/949ef534-07f5-4138-8b79-aae16a71310c/resourceGroups/flkelly-neu-identity-2/providers/Microsoft.ManagedIdentity/userAssignedIdentities/neu-mi-1'
param psScriptLocation string = 'https://raw.githubusercontent.com/lukearp/Azure-IAC-Bicep/master/Scripts/Restart-Vms/restart-vms.ps1'
param addressSpacePrefix string = '10.0.0.0/24'
param vnetPrefix string = '10.0.0.0/25'
param vnetName string = 'flkelly-adds-vnet'
param managedIdentityName string = 'flkelly-neu-msi1'
param avSetName string = 'flkelly-neu-avset-1'

var domainUserName = newForest == true ? '${split(domainFqdn,'.')[0]}\\${localAdminUsername}' : domainAdminUsername
var domainPassword = newForest == true ? localAdminPassword : domainAdminPassword
var domainSite = newForest == true ? 'Default-First-Site-Name' : site
resource nics 'Microsoft.Network/networkInterfaces@2020-11-01' = [for i in range(0, count): {
  name: '${vmNamePrefix}-${i + 1}-nic'
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
}]

module vnet 'vnet.bicep' = {
  name: 'vnet-deploy'
  //scope: rg
  params: {
    vnetName: vnetName
    addressSpacePrefix: addressSpacePrefix
    vnetPrefix: vnetPrefix
  }
}

module mangedIdentity 'mi.bicep' = {
  name: 'deploy-managedIdentity'
  params: {
    managedIdentityName: managedIdentityName
  }
  
}

module avSet 'avset.bicep' = if (zones == []) {
  name: 'deploy-avset'
  params :{
    avSetName: avSetName
  }  
}





module nicsDns 'nicDns.bicep' = {
  name: 'DNS-Set'
  params: {
    dnsServers: dnsServers
    nics: [for i in range(0, count): {
      name: nics[i].name
      ipConfigurations: nics[i].properties.ipConfigurations
    }]
    count: count
    location: location
  }
}

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


module vmProperties 'vmPropertiesBuilder.bicep' = {
  name: 'Properties-Builder'
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

resource dc1 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: '${vmNamePrefix}-1'
  location: location
  zones: zones[0]
  properties: vmProperties.outputs.vmProperties[0]
}

resource dc1Extension 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${vmNamePrefix}-1/DC-Creation'
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
  location: location
  name: '${dc1.name}-rebootDc'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}':{}
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
}

resource otherDc 'Microsoft.Compute/virtualMachines@2020-12-01' = if(count > 1) {
  dependsOn: [
    rebootDc1
  ]
  location: location
  name: '${vmNamePrefix}-2'
  zones: zones[1]
  properties: vmProperties.outputs.vmProperties[1]
}

resource otherDcExtension 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = if(count > 1){
  name: '${vmNamePrefix}-2/DC-Creation'
  location: location
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
  location: location
  name: '${otherDc.name}-rebootOtherVms'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}':{}
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

output username string = domainUserName
