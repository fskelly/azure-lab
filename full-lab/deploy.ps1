## IDENTITY - AD

## resource group name to be created
## location to be deployed into
$identityRGLocation = read-host "Enter the location for the IDENTITY resource group."
$identityRGName = read-host "Enter the name of the IDENTITY resource group to be created."


## subscription id for Managed Identity
$subID = read-host "Please enter your Sub ID, used fo the managed identity."


## add tags if you want to add metadata
$identityRGTags = @{"Purpose"="Identity"; "Can Be Deleted"="no"; "IaC"="Bicep💪"}
#use this command when you need to create a new resource group for your deployment
$identityRG = New-AzResourceGroup -Name $identityRGName -Location $identityRGLocation 
New-AzTag -ResourceId $identityRG.ResourceId -Tag $identityRGTags

## Bicep File name
$identityBicepFile = ".\01-adds\main.bicep"
$identityDeploymentName = (($identityBicepFile).Substring(2)).Replace("\","-") + "-" +(get-date -Format ddMMyyyy-hhmmss) + "-deployment"
New-AzResourceGroupDeployment -ResourceGroupName $identityRGName -TemplateFile $identityBicepFile -DeploymentName $identityDeploymentName -rgName $identityRGName -subID $subID

## CONNECTIVITY - networking

#$identityVnetID = (Get-AzResourceGroupDeployment -ResourceGroupName $identityRGName -Name $identityDeploymentName).Outputs.vnetID.value
$identityVnetName = (Get-AzResourceGroupDeployment -ResourceGroupName $identityRGName -Name $identityDeploymentName).Outputs.vnetName.value

$connectivityRGLocation = read-host "Enter the location for the resource group."
$connectivityRGName = read-host "Enter the name of the resource group to be created."

## add tags if you want to add metadata
$connectivityRGTags = @{"Purpose"="Connectivity"; "Can Be Deleted"="no"; "IaC"="Bicep💪"}
#use this command when you need to create a new resource group for your deployment
$connectivityRG = New-AzResourceGroup -Name $connectivityRGName -Location $connectivityRGLocation 
New-AzTag -ResourceId $connectivityRG.ResourceId -Tag $connectivityRGTags

## Bicep File name
$connectivityBicepFile = ".\02-restOfLab\mainNONRG.bicep"
$connectivityDeploymentName = (($connectivityBicepFile).Substring(2)).Replace("\","-") + "-" +(get-date -Format ddMMyyyy-hhmmss) + "-deployment"
New-AzResourceGroupDeployment -ResourceGroupName $connectivityRGName -TemplateFile $connectivityBicepFile -DeploymentName $connectivityDeploymentName -identityVnetRG $identityRGName -identityVnetName $identityVnetName