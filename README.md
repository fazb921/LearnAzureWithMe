
# Azure Bicep Template for VM Deployment

This Bicep template automates the deployment of Virtual Machines (VMs) within Azure. It allows users to specify whether to create new or use existing Virtual Networks (VNets) and Subnets, as well as configure network security.

## Parameters

- **numberOfVMs**: Number of VMs to create (int)
- **location**: Location for resource deployment (string, defaults to resource group location)
- **adminUsername**: Admin username for the VM (string)
- **adminPassword**: Admin password for the VM (secure string)
- **newOrExistingVirtualNetwork**: Choose between 'new' or 'existing' for the Virtual Network (string)
- **newOrExistingSubnet**: Choose between 'new' or 'existing' for the Subnet (string)
- **existingVirtualNetworkName**: Name of the existing Virtual Network (string)
- **existingSubnetName**: Name of the existing Subnet (string)
- **networkSecurityGroupName**: Name for the new Network Security Group (string)
- **newVirtualNetworkName**: Name for the new Virtual Network (string)
- **newSubnet**: Name for the new Subnet (string)
- **addressPrefix**: Address prefix for the new Subnet (string)
- **vmName**: Base name for the VM (string)
- **vmSize**: Size of the VM (string, defaults to 'Standard_B1s')

## Deployment Overview

This template allows for the deployment of multiple VMs with a specified network configuration. Users can opt to create new VNets and Subnets or use existing ones, ensuring flexibility in network setup.

## Important Note
If you choose to create a new VNet, specifying an existing subnet will not work. Ensure that you are either creating new resources or using existing resources correctly.

## Azure Free Services Eligibility
Most resources specified in this Bicep template can be used under the Azure Free Tier, provided you stay within the limits:
- **VMs**: Standard_B1s VMs are eligible, but only one B1S VM can be used for free for up to 750 hours per month. Additional VMs will incur charges.
- **Network Security Groups**: Free to create and use, but traffic governed by rules may incur data transfer charges.
- **Virtual Networks and Subnets**: Free to create and use, but data transfers may incur charges.
- **Public IP Addresses**: Charges apply for unassigned Public IPs, but assigned ones are usually free.
- **Storage**: The first 64 GB of standard storage is free, but additional storage or premium types may incur charges.
- **Operating System Costs**: Licensing costs for Windows Server images may lead to additional charges.

For detailed pricing information, check the [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/) and the [Azure Free Account](https://azure.microsoft.com/en-us/free/) page.

