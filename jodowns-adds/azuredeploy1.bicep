@description('The name of the administrator account of the new VM and domain')
param adminUsername string

@description('The password for the administrator account of the new VM and domain')
@secure()
param adminPassword string

@description('The FQDN of the Active Directory Domain to be created')
param domainName string

@description('The DNS prefix for the public IP address used by the Load Balancer')
param dnsPrefix string

@description('Size of the VM for the controller')
param vmSize string = 'Standard_D2s_v3'

@description('The location of resources, such as templates and DSC modules, that the template depends on')
param artifactsLocation string = deployment().properties.templateLink.uri

@description('Auto-generated token to access _artifactsLocation. Leave it blank unless you need to provide your own value.')
@secure()
param artifactsLocationSasToken string = ''

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Virtual network address range.')
param virtualNetworkAddressRange string = '172.16.0.0/23'

@description('Private IP address.')
param privateIPAddress string = '172.16.0.4'

@description('Subnet name.')
param subnetName string = 'AADS-Subnet'

@description('Subnet IP range.')
param subnetRange string = '172.16.0.0/27'

@description('prefix for resources.')
param prefix string

@description('shortcode for region.')
param regionShortCode string

var loadBalancerName_var = '${prefix}-${regionShortCode}-id-lb1'
var availabilitySetName_var = '${prefix}-${regionShortCode}-id-ad-as1'
var publicIPAddressName_var = '${prefix}-${regionShortCode}-id-ad-pip1'
var networkInterfaceName_var = '${prefix}-${regionShortCode}-id-ad-nic1'
var inboundNatRulesName = '${prefix}-${regionShortCode}-id-lb-nat-rdp'
var backendAddressPoolName = '${prefix}-${regionShortCode}-id-lb-be1'
var loadBalancerFrontEndIPName = '${prefix}-${regionShortCode}-id-lb-fe1'
var virtualNetworkName = '${prefix}-${regionShortCode}-id-ss-vnet'
var virtualMachineName_var = '${regionShortCode}-advm1'

resource publicIPAddressName 'Microsoft.Network/publicIPAddresses@2019-02-01' = {
  name: publicIPAddressName_var
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: dnsPrefix
    }
  }
}

resource availabilitySetName 'Microsoft.Compute/availabilitySets@2019-03-01' = {
  location: location
  name: availabilitySetName_var
  properties: {
    platformUpdateDomainCount: 20
    platformFaultDomainCount: 2
  }
  sku: {
    name: 'Aligned'
  }
}

module VNet './nestedtemplates/vnet.bicep' /*TODO: replace with correct path to [uri(parameters('_artifactsLocation'), concat('nestedtemplates/vnet.json', parameters('_artifactsLocationSasToken')))]*/ = {
  name: 'VNet'
  params: {
    virtualNetworkName: virtualNetworkName
    virtualNetworkAddressRange: virtualNetworkAddressRange
    subnetName: subnetName
    subnetRange: subnetRange
    location: location
  }
}

resource loadBalancerName 'Microsoft.Network/loadBalancers@2019-02-01' = {
  name: loadBalancerName_var
  location: location
  properties: {
    frontendIPConfigurations: [
      {
        name: loadBalancerFrontEndIPName
        properties: {
          publicIPAddress: {
            id: publicIPAddressName.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: backendAddressPoolName
      }
    ]
    inboundNatRules: [
      {
        name: inboundNatRulesName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', loadBalancerName_var, loadBalancerFrontEndIPName)
          }
          protocol: 'Tcp'
          frontendPort: 3389
          backendPort: 3389
          enableFloatingIP: false
        }
      }
    ]
  }
}

resource networkInterfaceName 'Microsoft.Network/networkInterfaces@2019-02-01' = {
  name: networkInterfaceName_var
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: privateIPAddress
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
          }
          loadBalancerBackendAddressPools: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName_var, backendAddressPoolName)
            }
          ]
          loadBalancerInboundNatRules: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/inboundNatRules', loadBalancerName_var, inboundNatRulesName)
            }
          ]
        }
      }
    ]
  }
  dependsOn: [
    VNet
    loadBalancerName
  ]
}

resource virtualMachineName 'Microsoft.Compute/virtualMachines@2019-03-01' = {
  name: virtualMachineName_var
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    availabilitySet: {
      id: availabilitySetName.id
    }
    osProfile: {
      computerName: virtualMachineName_var
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2016-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: '${virtualMachineName_var}_OSDisk'
        caching: 'ReadOnly'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      dataDisks: [
        {
          name: '${virtualMachineName_var}_DataDisk'
          caching: 'ReadWrite'
          createOption: 'Empty'
          diskSizeGB: 20
          managedDisk: {
            storageAccountType: 'StandardSSD_LRS'
          }
          lun: 0
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaceName.id
        }
      ]
    }
  }
  dependsOn: [
    loadBalancerName
  ]
}

resource virtualMachineName_CreateADForest 'Microsoft.Compute/virtualMachines/extensions@2019-03-01' = {
  parent: virtualMachineName
  name: 'CreateADForest'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.19'
    autoUpgradeMinorVersion: true
    settings: {
      ModulesUrl: uri(artifactsLocation, 'DSC/CreateADPDC.zip${artifactsLocationSasToken}')
      ConfigurationFunction: 'CreateADPDC.ps1\\CreateADPDC'
      Properties: {
        DomainName: domainName
        AdminCreds: {
          UserName: adminUsername
          Password: 'PrivateSettingsRef:AdminPassword'
        }
      }
    }
    protectedSettings: {
      Items: {
        AdminPassword: adminPassword
      }
    }
  }
}

module UpdateVNetDNS 'nestedtemplates/vnet-with-dns-server.bicep' /*TODO: replace with correct path to [uri(parameters('_artifactsLocation'), concat('nestedtemplates/vnet-with-dns-server.json', parameters('_artifactsLocationSasToken')))]*/ = {
  name: 'UpdateVNetDNS'
  params: {
    virtualNetworkName: virtualNetworkName
    virtualNetworkAddressRange: virtualNetworkAddressRange
    subnetName: subnetName
    subnetRange: subnetRange
    DNSServerAddress: [
      privateIPAddress
    ]
    location: location
  }
  dependsOn: [
    virtualMachineName_CreateADForest
  ]
}
