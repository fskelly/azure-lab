## CONNECTIVITY - P2S / S2S

## location to be deployed into
$connectivityRGLocation = read-host "Enter the location for the CONNECTIVITY resource group."

## Bicep File name
$connectivityBicepFile = ".\main.bicep"
$connectivityDeploymentName = (($connectivityBicepFile).Substring(2)).Replace("\","-") + "-" +(get-date -Format ddMMyyyy-hhmmss) + "-deployment"
##New-AzResourceGroupDeployment -ResourceGroupName $identityRGName -TemplateFile $identityBicepFile -DeploymentName $identityDeploymentName -rgName $identityRGName -subID $subID
New-AzSubscriptionDeployment -Name $connectivityDeploymentName -TemplateFile $connectivityBicepFile -connectivityRGLocation $connectivityRGLocation -verbose #-subID $subID -verbose -Location $identityRGLocation
