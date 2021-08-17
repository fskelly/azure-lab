param resourceTags object = {
  Environment: 'Dev'
  Project: 'Tutorial'
  Purpose: 'Identity'
}

// Param Section
param vnetName string
param addressSpacePrefix string
param vnetPrefix string
param vnetLocation string = resourceGroup().location
param bastionSubnetName string
param bastionSubnetIpPrefix string
param nsgName string

// VNET 
resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetName
  tags: resourceTags
  location: vnetLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressSpacePrefix
      ]
    }
    subnets: [
      {
        name: 'ADDS-Subnet'
        properties: {
          addressPrefix: vnetPrefix
          networkSecurityGroup: {
            id: networkSecurityGroupADDS.id
          }
        }
      }
      {
        name: bastionSubnetName
        properties: {
          addressPrefix: bastionSubnetIpPrefix
        }
      }
    ]
  }
}


resource networkSecurityGroupADDS 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: nsgName
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'allow_RDP_to_AD_Servers'
        properties: {
          description: 'allow_RDP_to_AD_Servers'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: vnetPrefix
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'allow_AD_SMTP'
        properties: {
          description: 'allow_RDP_to_AD_Servers'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '25'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: vnetPrefix
          access: 'Allow'
          priority: 121
          direction: 'Inbound'
        }
      }
      {
        name: 'allow_AD_WINS'
        properties: {
          description: 'allow_AD_WINS'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '42'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: vnetPrefix
          access: 'Allow'
          priority: 122
          direction: 'Inbound'
        }
      }
      {
        name: 'allow_AD_Repl'
        properties: {
          description: 'allow_AD_Repl'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '135'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: vnetPrefix
          access: 'Allow'
          priority: 123
          direction: 'Inbound'
        }
      }
      {
        name: 'allow_AD_NetBIOS'
        properties: {
          description: 'allow_AD_NetBIOS'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '137'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: vnetPrefix
          access: 'Allow'
          priority: 124
          direction: 'Inbound'
        }
      }
      {
        name: 'allow_AD_netlogin'
        properties: {
          description: 'allow_AD_netlogin'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '139'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: vnetPrefix
          access: 'Allow'
          priority: 125
          direction: 'Inbound'
        }
      }
      {
        name: 'allow_AD_LDAP'
        properties: {
          description: 'allow_AD_LDAP'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '389'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: vnetPrefix
          access: 'Allow'
          priority: 126
          direction: 'Inbound'
        }
      }
      {
        name: 'allow_AD_LDAP_udp'
        properties: {
          description: 'allow_AD_LDAP_udp'
          protocol: 'Udp'
          sourcePortRange: '*'
          destinationPortRange: '389'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: vnetPrefix
          access: 'Allow'
          priority: 127
          direction: 'Inbound'
        }
      }
      {
        name: 'allow_AD_LDAPS'
        properties: {
          description: 'allow_AD_LDAPS'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '636'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: vnetPrefix
          access: 'Allow'
          priority: 128
          direction: 'Inbound'
        }
      }
      {
        name: 'allow_AD_LDAP_GC'
        properties: {
          description: 'allow_AD_LDAP_GC'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3268-3269'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: vnetPrefix
          access: 'Allow'
          priority: 129
          direction: 'Inbound'
        }
      }
      {
        name: 'allow_AD_KRB'
        properties: {
          description: 'allow_AD_KRB'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '88'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: vnetPrefix
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
      {
        name: 'allow_AD_KRB_udp'
        properties: {
          description: 'allow_AD_KRB_upd'
          protocol: 'Udp'
          sourcePortRange: '*'
          destinationPortRange: '88'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: vnetPrefix
          access: 'Allow'
          priority: 131
          direction: 'Inbound'
        }
      }
      {
        name: 'allow_AD_DNS'
        properties: {
          description: 'allow_AD_DNS'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '53'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: vnetPrefix
          access: 'Allow'
          priority: 132
          direction: 'Inbound'
        }
      }
      {
        name: 'allow_AD_DNS_udp'
        properties: {
          description: 'allow_AD_DNS_udp'
          protocol: 'Udp'
          sourcePortRange: '*'
          destinationPortRange: '53'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: vnetPrefix
          access: 'Allow'
          priority: 133
          direction: 'Inbound'
        }
      }
      {
        name: 'allow_AD_445'
        properties: {
          description: 'allow_AD_445'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '445'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: vnetPrefix
          access: 'Allow'
          priority: 134
          direction: 'Inbound'
        }
      }
      {
        name: 'allow_AD_445_udp'
        properties: {
          description: 'allow_AD_445_udp'
          protocol: 'Udp'
          sourcePortRange: '*'
          destinationPortRange: '445'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: vnetPrefix
          access: 'Allow'
          priority: 135
          direction: 'Inbound'
        }
      }
      {
        name: 'allow_AD_SOAP'
        properties: {
          description: 'allow_AD_SOAP'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '9389'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: vnetPrefix
          access: 'Allow'
          priority: 136
          direction: 'Inbound'
        }
      }
      {
        name: 'allow_AD_DFSR'
        properties: {
          description: 'allow_AD_DFSR'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '5722'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: vnetPrefix
          access: 'Allow'
          priority: 137
          direction: 'Inbound'
        }
      }
      {
        name: 'allow_AD_KRB2'
        properties: {
          description: 'allow_AD_KRB2'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '464'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: vnetPrefix
          access: 'Allow'
          priority: 138
          direction: 'Inbound'
        }
      }
      {
        name: 'allow_AD_KRB2_udp'
        properties: {
          description: 'allow_AD_KRB2_udp'
          protocol: 'Udp'
          sourcePortRange: '*'
          destinationPortRange: '464'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: vnetPrefix
          access: 'Allow'
          priority: 139
          direction: 'Inbound'
        }
      }
      {
        name: 'allow_AD_time'
        properties: {
          description: 'allow_AD_time'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '123'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: vnetPrefix
          access: 'Allow'
          priority: 140
          direction: 'Inbound'
        }
      }
      {
        name: 'allow_AD_auth'
        properties: {
          description: 'allow_AD_auth'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '137-138'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: vnetPrefix
          access: 'Allow'
          priority: 141
          direction: 'Inbound'
        }
      }
      {
        name: 'allow_AD_ephemeral'
        properties: {
          description: 'allow_AD_ephemeral'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '49152-65535'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: vnetPrefix
          access: 'Allow'
          priority: 142
          direction: 'Inbound'
        }
      }
      {
        name: 'allow_AD_ephemeral_udp'
        properties: {
          description: 'allow_AD_ephemeral_udp'
          protocol: 'Udp'
          sourcePortRange: '*'
          destinationPortRange: '49152-65535'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: vnetPrefix
          access: 'Allow'
          priority: 143
          direction: 'Inbound'
        }
      }
      {
        name: 'deny_AD_Other_TCP'
        properties: {
          description: 'deny_AD_Other_TCP'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: vnetPrefix
          access: 'Deny'
          priority: 200
          direction: 'Inbound'
        }
      }
      {
        name: 'deny_AD_Other_UDP'
        properties: {
          description: 'deny_AD_Other_UDP'
          protocol: 'Udp'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: vnetPrefix
          access: 'Deny'
          priority: 201
          direction: 'Inbound'
        }
      }
    ]
  }
}


output vnetID string = vnet.id
output subnetName string = vnet.properties.subnets[0].name
output bastionSubnetID string = vnet.properties.subnets[1].id
