@description('How many VMs are to be created')
param numberOfVMs int


@description('location of the resource')
param location string = resourceGroup().location
@description('Admin Username for the VM')
param adminUsername string
@secure()
param adminPassword string 


@allowed([
  'new'
  'existing'
])
@description('New or Existing VirtualNetwork')
param newOrExistingVirtualNetwork string


@allowed([
  'new'
  'existing'
])
@description('New or Existing SubNet')
param newOrExistingSubnet string


@description('VNET to be used for resources')
param existingVirtualNetworkName string
param existingSubnetName string


@description('Set a name for a new networkSecurityGroup')
param networkSecurityGroupName string


@description('Name of the new VNET to be created')
param newVirtualNetworkName string


@description('Name of the new Subnet')
param newSubnet string


@description('Specify the Address Prefix for your Subnet (if new)')
param addressPrefix string


var virtualNetworkToUse = newOrExistingVirtualNetwork == 'new' ? newVirtualNetworkName : existingVirtualNetworkName


var subnetToUse = newOrExistingSubnet == 'new' ? newSubnet : existingSubnetName


@description('Name of the VM')
param vmName string


@allowed([
  'Standard_B1s'
])
@description('Size of the VM') 
param vmSize string = 'Standard_B1s'


// Creating a new NSG for the deployment and setting the rules for it
resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-SSH'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 100
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange:'22' // Allow SSH
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'Allow-RDP'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 110
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '3389' // Allow RDP
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
  }


  // Creates a new Virtual Network (if specified)
  resource newVirtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = if (newOrExistingVirtualNetwork == 'new') {
    name: newVirtualNetworkName
    location: location
    properties: {
      addressSpace: {
        addressPrefixes: [addressPrefix]
      }
    }
  }


// Creates a new subnet using the name specified in the parameter 'newSubnet' for the specified, existing VNet
resource subnetNewForExistingVnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = if (newOrExistingSubnet == 'new' && newOrExistingVirtualNetwork == 'existing') {
  name: subnetToUse
  parent: virtualNetwork
  properties: {
   addressPrefix: addressPrefix
   }
}


// Creates a new subnet using the name specified in the parameter 'newSubnet' for a new, specified VNet (newVirtualNetwork)
resource subnetNewForNewVnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = if (newOrExistingSubnet == 'new' && newOrExistingVirtualNetwork == 'new') {
  name: subnetToUse
  parent: virtualNetwork
  properties: {
   addressPrefix: addressPrefix
  }
}


// Referencing the existing Virtual Network
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = if (newOrExistingVirtualNetwork == 'existing') {
  name: virtualNetworkToUse
  location: location
}


//Referencing the existing Subnet
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = if (newOrExistingSubnet == 'existing') {
  parent: virtualNetwork
  name: subnetToUse
}


// Creating NICs for the VMs to use
resource networkInterface 'Microsoft.Network/networkInterfaces@2024-01-01' = [for nic in range(0, numberOfVMs): {
  name: '${vmName}${nic}-${'NIC'}'
  location: location
  properties: {
    ipConfigurations: [{
      name: '${vmName}-${nic}-${'IPconfig'}'
      properties: {
        subnet: {
          id: newOrExistingSubnet == 'new' && newOrExistingVirtualNetwork == 'new' ? subnetNewForNewVnet.id : newOrExistingSubnet == 'new' && newOrExistingVirtualNetwork == 'existing' ? subnetNewForExistingVnet.id : subnet.id
        }
        privateIPAllocationMethod: 'Dynamic'
      }
    }]
  }
  dependsOn: [
    networkSecurityGroup
  ]
}]



// Deploying multiple VMs
resource virtualMachine 'Microsoft.Compute/virtualMachines@2024-07-01' = [for vm in range(0,numberOfVMs): {
  name: '${vmName}${vm}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
    computerName: 'mainjumphost'
    adminUsername: adminUsername
    adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        sku: '2019-DataCenter-smalldisk'
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        version: 'latest'
      }
      osDisk: {
          createOption: 'FromImage'
          diskSizeGB: 64
          osType: 'Windows'
          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }
      }
    }
  networkProfile: {
    networkInterfaces: [
      {
        id:networkInterface[vm].id
      }
    ]
  }
  }
  dependsOn: [
     networkInterface
  ]
}]
output vmNames array = [for vm in range(0, numberOfVMs): '${vmName}${vm}']
