param resourceTags object = {
  Environment: 'Dev'
  Project: 'Tutorial'
  Purpose: 'Identity'
  IaC: 'Bicep💪'
}

param vmNamePrefix string
param location string
param zones array
param vmProperties array
param dscConfigScript string
param domainUserName string
param domainFqdn string
param domainSite string
param newForest bool
@secure()
param domainPassword string
param fullManagedIdentityID string
param psScriptLocation string


resource dc2 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: '${vmNamePrefix}-2'
  tags: resourceTags
  location: location
  zones: zones[0]
  properties: vmProperties[0]
}

resource dc2Extension 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${vmNamePrefix}-2/DC-Creation'
  tags: resourceTags
  location: location
  dependsOn: [
    dc2
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

resource rebootDc2 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  kind: 'AzurePowerShell'
  tags: resourceTags
  location: location
  name: '${dc2.name}-rebootDc'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${fullManagedIdentityID}':{}

    }  
  } 
  properties: {
    arguments: '${array(dc2.name)} ${resourceGroup().name} ${subscription().subscriptionId}'
    primaryScriptUri: psScriptLocation 
    azPowerShellVersion: '5.9'
    retentionInterval: 'PT1H'    
  } 
  dependsOn: [
    dc2Extension 
  ]    
}
