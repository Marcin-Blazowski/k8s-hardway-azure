Previous: [Prerequisites](docs/01-prerequisites.md)

# Clean-up Azure Resources

- Open Azure Cloud Shell (PowerShell, portal based or a command line based on your workstation).

- Run PowerShell command to get the name of your resource group:

`Get-AzResourceGroup -Name 'k8s-test*'`

- Make sure this is the resource group with your resources.

- Run PowerShell command to remove the resource group and resources inside:

`Get-AzResourceGroup -Name 'k8s-test*' | Remove-AzResourceGroup -Force -AsJob`

If you prefer Bash you can try this one:

`az group list --query "[?starts_with(name,'k8s-test')].[name]" --output tsv | xargs -L1 bash -c 'az group delete --name $0 --no-wait --yes'`