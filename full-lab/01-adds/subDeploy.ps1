## IDENTITY - AD

## location to be deployed into
$identityRGLocation = read-host "Enter the location for the IDENTITY resource group."

## subscription id for Managed Identity
$subID = read-host "Please enter your Sub ID, used fo the managed identity."

## Bicep File name
$identityBicepFile = ".\main.bicep"
$identityDeploymentName = (($identityBicepFile).Substring(2)).Replace("\","-") + "-" +(get-date -Format ddMMyyyy-hhmmss) + "-deployment"
##New-AzResourceGroupDeployment -ResourceGroupName $identityRGName -TemplateFile $identityBicepFile -DeploymentName $identityDeploymentName -rgName $identityRGName -subID $subID
New-AzSubscriptionDeployment -Name $identityDeploymentName -TemplateFile $identityBicepFile -rgIdentityLocation $identityRGLocation -subID $subID -verbose -Location $identityRGLocation
