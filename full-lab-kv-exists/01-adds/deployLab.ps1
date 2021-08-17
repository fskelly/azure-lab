$rgLocation = "westeurope"
$subID = "949ef534-07f5-4138-8b79-aae16a71310c"   
$bicepFile = ".\deploy.bicep"
$deploymentName = (($bicepFile).Substring(2)).Replace("\","-") + "-" +(get-date -Format ddMMyyyy-hhmmss) + "-deployment"
New-AzSubscriptionDeployment -Name $deploymentName -TemplateFile $bicepFile -identityRGLocation $rgLocation -subID $subID -verbose -Location $rgLocation