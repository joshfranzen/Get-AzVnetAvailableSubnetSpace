# Get-AzVnetAvailableSubnetSpace
Output ranges where there is available room for new subnets.

# Usage

From the directory where the script is stored run:

    .\subnetspacefinder.ps1 -SubscriptionName $subscriptionname -VnetName $vnetname -SubnetSize $subnetsize
    
This should return an output of the first available cidr of the requested size:

    cidr
    ----
    10.251.38.16/28

or without a subnetsize:

    .\subnetspacefinder.ps1 -SubscriptionName $subscriptionname -VnetName $vnetname 
    
which chould return an output of any unused gaps in the IP space:

    PreFix    MaxSubnetSize EndIP StartIP IPCount
    ------    ------------- ----- ------- -------
    10.251.38            25   255      16     240


