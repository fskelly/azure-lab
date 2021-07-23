param userNameValue string //= 'domain-admin-username'
param userName string
param vaultName string
param userPasswordValue string //= 'domain-admin-password'
@secure()
param userPassword string

// create secret - username
resource userNameSecret 'Microsoft.KeyVault/vaults/secrets@2018-02-14' = {
  name: '${vaultName}/${userNameValue}'
  properties: {
    value: userName
  }
}

resource userPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2018-02-14' = {
  name: '${vaultName}/${userPasswordValue}'
  properties: {
    value: userPassword
  }
}
