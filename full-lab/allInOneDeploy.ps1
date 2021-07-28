## CONNECTIVITY - P2S / S2S

## location to be deployed into
#$allInOneRGLocation = read-host "Enter the location for the resource group(s)."

## Bicep File name
$allInOneBicepFile = ".\allInOne.bicep"
$allInOneDeploymentName = (($allInOneBicepFile).Substring(2)).Replace("\","-") + "-" +(get-date -Format ddMMyyyy-hhmmss) + "-deployment"
##New-AzResourceGroupDeployment -ResourceGroupName $identityRGName -TemplateFile $identityBicepFile -DeploymentName $identityDeploymentName -rgName $identityRGName -subID $subID
New-AzSubscriptionDeployment -Name $allInOneDeploymentName -TemplateFile $allInOneBicepFile -verbose #-connectivityRGLocation $connectivityRGLocation -verbose #-subID $subID -verbose -Location $identityRGLocation
