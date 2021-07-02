##Populate as needed for housing AD components
$rgLocation = read-host "Which Location?"
$rgName = "Please provide RG Name"
$fileURI = "Please provide the url for the JSON file"
$paramatersURI = "Please provide the url for the parameters file"

## add tags if you want to add metadata
$tags = @{"Purpose"="Identity"; "Can Be Deleted"="no"}

#use this command when you need to create a new resource group for your deployment
$rg = New-AzResourceGroup -Name $rgName -Location $rgLocation 
New-AzTag -ResourceId $rg.ResourceId -Tag $tags

New-AzResourceGroup -Name $rgName -Location $rgLocation #use this command when you need to create a new resource group for your deployment

##if you want to use a parameter file
New-AzResourceGroupDeployment -ResourceGroupName $rgName -TemplateUri $fileURI -TemplateParameterUri $paramatersURI
