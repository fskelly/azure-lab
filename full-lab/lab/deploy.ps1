## location to be deployed into
$rgLocation = "northeurope"
$rgName = "flkelly-neu-identity-test-101"

$subID = read-host "Please enter your Sub ID, used fo the managed identity."

## add tags if you want to add metadata
$tags = @{"Purpose"="Identity"; "Can Be Deleted"="no"}
#use this command when you need to create a new resource group for your deployment
$rg = New-AzResourceGroup -Name $rgName -Location $rgLocation 
New-AzTag -ResourceId $rg.ResourceId -Tag $tags

## Bicep File name
$bicepFile = ".\main.bicep"
$deploymentName = ($bicepFile).Substring(2) + "-" +(get-date -Format ddMMyyyy-hhmmss) + "-deployment"
New-AzResourceGroupDeployment -ResourceGroupName $rgName -TemplateFile $bicepFile -DeploymentName $deploymentName -prefix flkelly -regionShortcode neu -rgName $rgName -subID $subID

