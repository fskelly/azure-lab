## location to be deployed into
$rgLocation = "northeurope"

##variables needed for previously creatd VNET (Identity VNET)
$identityVnetRG = read-host "Resource Group of Identity Vnet"
$identityVnetName = read-host "Name of Identity Vnet"

## Bicep File name
$bicepFile = ".\main.bicep"
$deploymentName = ($bicepFile).Substring(2) + "-" +(get-date -Format ddMMyyyy-hhmmss) + "-deployment"
New-AzSubscriptionDeployment -TemplateFile $bicepFile -Location $rgLocation -DeploymentName $deploymentName -identityVnetRG $identityVnetRG -identityVnetName $identityVnetName