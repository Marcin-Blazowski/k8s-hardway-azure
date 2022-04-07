Previous: [Smoke Test](15-smoke-test.md)

# Lab automation

If you have some problems with labs and you want to make sure that it is going to work you can provision the whole kubernetes cluster automatically. I created a dedicated ARM template to do this.

- Click the button below to deploy ARM template on your Azure cloud. Use CTRL + Click to open in a new tab.

[![Deploy To Azure](../docs/images/deploy-to-azure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FMarcin-Blazowski%2Fk8s-hardway-azure%2Fmain%2Fazure%2Fazuredeploy-k8s-hardway-automation.json)

- Fill parameters form the same way as described in [Compute resources](02-compute-resources.md).

- You should get the k8s cluster running on 5 VMs. You can review it is up and running by executing smoke tests on master-1 or worker-2 nodes: [Smoke Test](15-smoke-test.md).

You should get 5 VMs created with the k8s cluster provisioned by shell scripts. You can review scripts here [Automation scripts](../azure/ubuntu/azure/). "*automation-wrapper.sh" are the ones you are looking for.


Previous: [Smoke Test](15-smoke-test.md)