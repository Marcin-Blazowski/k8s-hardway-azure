Previous: [Prerequisites](docs/01-prerequisites.md)

# Provisioning Compute Resources

Note: You must have active Azure subscription at this point.

Log in into [Azure Portal](https://portal.azure.com) in a separate Internet browser tab.

## Provision Compute Resources

- Click the button below to deploy ARM template on your Azure cloud. Use CTRL + Click to open in a new tab.

[![Deploy To Azure](../docs/images/deploy-to-azure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FMarcin-Blazowski%2Fk8s-hardway-azure%2Fmain%2Fazure%2Fazuredeploy-k8s-hardway.json)

- Select your subscription.

- Click "Create new" to create dedicated resource group for your Kubernetest Cluster (k8s).
Recommendation: Use "k8s-test-rg" or any other similar name. Note the name of the resource group. You will need it to clean up resources to limit the cost of the cloud.

- Select region (the one which is close to you is the best choice).

- Note: I assume that you have SSH key pair. If you do not have one create it and use with your preferred SSH client later in this tutorial.

- Select "Use existing public key" for "SSH public key source" or use any other option if you know what your are doing.

- Put you SSH public key into "Admin Ssh Public Key".

- Set your VM sizes. I do recommend "Standard_B1ms" for master nodes and "Standard_B1s" for workers and loadbalancer. If you use Azure free account you will have to select smallest supported by your subscription (B sizes were not supported by my free account).

- Click "Review + Create" and then "Create".

- It should take about 5 minutes to provision all resources.

## Compute Resources

The deployment should create what is described below:

- Deploys 5 VMs - 2 Master, 2 Worker and 1 Loadbalancer with the name 'k8s-hardway* '
    > This is the default settings. This can be changed by setting template parameters.
    > If you choose to change these settings, please be careful while following the guide.

- Review the architecture overview in the main chapter [K8s The Hard Way](../README.md)

- Sets IP addresses in the range 10.0.0.0/25

    | VM            |  VM Name                   | Purpose       | IP       | 
    | ------------  | ----------------------     |:-------------:|:--------:| 
    | master-1      | k8s-hardway-master-1       | Master        | 10.0.0.x | 
    | master-2      | k8s-hardway-master-2       | Master        | 10.0.0.x | 
    | worker-1      | k8s-hardway-worker-1       | Worker        | 10.0.0.x | 
    | worker-2      | k8s-hardway-worker-2       | Worker        | 10.0.0.x | 
    | loadbalancer  | kubernetes-ha-loadbalancer | LoadBalancer  | 10.0.0.x | 

    > These are the default settings. These can be changed the same way like hostnames but you will have to alter the guide accordingly.

- Installs Docker on Worker nodes (this is done automaatically on Worker nodes)
- Runs the below command on all nodes to allow for network forwarding in IP Tables.
  This is required for kubernetes networking to function correctly.
    > sysctl net.bridge.bridge-nf-call-iptables=1 (this is also done automatically on worker nodes)


## SSH to the nodes

### 2. SSH Using SSH Client Tools

Use your favourite SSH Terminal tool. Make sure your SSH client uses the SSH key you used while triggering deployment of resources above.

Review resources created. Get Public IP addresses of your VMs. Password based SSH authentication is disabled by default.

Log in into all VMs using the k8sadmin user name.


## Verify Environment

- Ensure all VMs are up
- Ensure VMs are assigned the above IP addresses
- Ensure you can SSH into these VMs using the IP and private keys
- Ensure the VMs can ping each other
- Ensure the worker nodes have Docker installed on them.
  > command `sudo docker version`

## Clean up your Environment

You can remove your resources if you are not going to continue the lab. Please use information provided here: [Delete Azure cloud resources](../docs/clean-up.md).

Move to the next step by clicking "Next" link below.

## Troubleshooting Tips

#### 1. Virtual network cannot be deleted. Public IP address cannot be deleted.
This happened to me multiple times while testing. I was not able to remove all resources because public IP was assigned to delete NIC. In such a case try what is below.

- Open your virtual network (k8s-hardway-vnet) "Overview".
- Go back to the home page of Azure Portal and open "Help + support".
- You network should be listed below "Have an issue with your resource?".
- Click "Troubleshoot".
- Select "Cannot delete Azure Virtual Network (VNet)" tile.
- Select "Cannot delete VNet becasue of VM/NIC/IP" problem.
- Wait for "Synchronize platform resources" process to complete.
- You should get "Resources are out-of-sync with Azure Resource Manager" message with "We have now synced them to resolve the issue." below.
- Wait a few hours (it says that 20 minutes should be enough but it was not the case for me).
- Open the resource group with your resources.
- Open public IP and disassiociate it from the NIC.
- Delete resources manually starting from IP, then NIC, then security group, and virutal network at the end.


Next: [Client tools](03-client-tools.md)

Previous: [Prerequisites](docs/01-prerequisites.md)