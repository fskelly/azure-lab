## VARIABLES

$subID = '949ef534-07f5-4138-8b79-aae16a71310c'
$deployLocation = 'northeurope'
$connectivityRGLocation = 'northeurope'
$identityRGLocation = 'northeurope'
$keyVaultRGLocation = 'northeurope'
$objectID = '4ad6d4e3-4556-4135-979d-bdbd3a63f4ef'
$tenantID = '17ca67c9-6ef2-4396-89dd-c8a769cc1991'

## Bicep File name
$allInOneBicepFile = ".\allInOne.bicep"
$allInOneDeploymentName = (($allInOneBicepFile).Substring(2)).Replace("\","-") + "-" +(get-date -Format ddMMyyyy-hhmmss) + "-deployment"
##New-AzResourceGroupDeployment -ResourceGroupName $identityRGName -TemplateFile $identityBicepFile -DeploymentName $identityDeploymentName -rgName $identityRGName -subID $subID
New-AzSubscriptionDeployment -Name $allInOneDeploymentName -TemplateFile $allInOneBicepFile -verbose -connectivityRGLocation $connectivityRGLocation -subID $subID -Location $deployLocation -identityRGLocation $identityRGLocation -objectID $objectID -tenantID $tenantID -keyVaultRGLocation $keyVaultRGLocation
