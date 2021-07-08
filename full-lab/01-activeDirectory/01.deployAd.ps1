##Populate as needed for housing AD components
$rgLocation = read-host "Which Location?"
$rgName = read-host "Please provide RG Name"
$fileURI = "https://raw.githubusercontent.com/fskelly/azure-lab/main/01-activeDirectory/templates/domaincontrollerAzureDeploy.json"

## add tags if you want to add metadata
$tags = @{"Purpose"="Identity"; "Can Be Deleted"="no"}

#use this command when you need to create a new resource group for your deployment
$rg = New-AzResourceGroup -Name $rgName -Location $rgLocation 
New-AzTag -ResourceId $rg.ResourceId -Tag $tags

New-AzResourceGroupDeployment -ResourceGroupName $rgName -TemplateUri $fileURI