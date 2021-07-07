
## location to be deployed into
$rgLocation = "northeurope"

## Bicep File name
$bicepFile = ".\main.bicep"
$deploymentName = ($bicepFile).Substring(2) + "-" +(get-date -Format ddMMyyyy-hhmmss) + "-deployment"
New-AzSubscriptionDeployment -TemplateFile $bicepFile -Location $rgLocation -DeploymentName $deploymentName
#New-AzResourceGroupDeployment -ResourceGroupName $rgName -TemplateFile $bicepFile -name $deploymentName
