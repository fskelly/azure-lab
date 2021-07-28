## resource group name to be created
## location to be deployed into
$rgLocation = read-host "Enter the location for the resource group."
$rgName = read-host "Enter the name of the resource group to be created."

## subscription id for Managed Identity
$subID = read-host "Please enter your Sub ID, used fo the managed identity."

## tenant id ofr Keyvault and object id
Get-AzTenant
$tenantID = read-host "Please enter your tenant ID - 'get-aztenant' can help here"
$objectID = read-host "Please enter the Object ID - can be gotten from Azure AD"

## add tags if you want to add metadata
$tags = @{"Purpose"="Security"; "Can Be Deleted"="no"}
#use this command when you need to create a new resource group for your deployment
$rg = New-AzResourceGroup -Name $rgName -Location $rgLocation 
New-AzTag -ResourceId $rg.ResourceId -Tag $tags

## Bicep File name
$bicepFile = ".\main.bicep"
$deploymentName = ($bicepFile).Substring(2) + "-" +(get-date -Format ddMMyyyy-hhmmss) + "-deployment"
New-AzResourceGroupDeployment -ResourceGroupName $rgName -TemplateFile $bicepFile -DeploymentName $deploymentName -tenant $tenantID -objectID $objectID -verbose