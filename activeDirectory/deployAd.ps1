##Populate as needed for housing AD components
$rgLocation = read-host "Which Location?"
$rgName = read-host "Please provide RG Name"
$fileURI = "https://raw.githubusercontent.com/fskelly/azure-lab/main/activeDirectory/templates/domiancontrollerAzureDeploy.json"

## add tags if you want to add metadata
$tags = @{"Purpose"="Identity"; "Can Be Deleted"="no"}

#use this command when you need to create a new resource group for your deployment
$rg = New-AzResourceGroup -Name $rgName -Location $rgLocation 
New-AzTag -ResourceId $rg.ResourceId -Tag $tags

New-AzResourceGroupDeployment -ResourceGroupName $rgName -TemplateUri $fileURI

##if you want to use a parameter file
#New-AzResourceGroupDeployment -ResourceGroupName $rgName -TemplateUri $fileURI -TemplateParameterUri $paramatersURI
