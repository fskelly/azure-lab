az login

$subID = '949ef534-07f5-4138-8b79-aae16a71310c'
$deployLocation = 'northeurope'
$connectivityRGLocation = 'northeurope'
$identityRGLocation = 'northeurope'
$keyVaultRGLocation = 'northeurope'
$objectID = '4ad6d4e3-4556-4135-979d-bdbd3a63f4ef'
$tenantID = '17ca67c9-6ef2-4396-89dd-c8a769cc1991'

## Bicep File name
$allInOneBicepFile = ".\allInOne.bicep"

az deployment sub create --template-file $allInOneBicepFile --location $deployLocation `
  --parameters subID=SubID connectivityRGLocation=$connectivityRGLocation identityRGLocation=$identityRGLocation objectID=$objectID tenantID=$tenantID keyVaultRGLocation=$keyVaultRGLocation