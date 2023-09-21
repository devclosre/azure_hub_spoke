# Implementing Hub and Spoke within Azure Cloud
1. I have created a 4 Resource groups and Networks, 1 for Hub, 1 for Dev, 1 for QA and 1 for Prod respectively.
2. Names for the resource groups are as follows:
   ## rg-hub, rg-dev, rg-qa and rg-prod
3. Names for the vnets are as follows:
   ## vnet-hub, vnet-dev, vnet-qa and vnet-prod
4. I have created a Gatewaysubnet, Public IP and VPN Gateway in the Hub Network.
5. Peering is done form Hub to all the Spokes (dev, qa and prod)
6. I have setup a p2p connection.
