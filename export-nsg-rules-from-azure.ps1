Connect-AzAccount -TenantId '<Tenand-ID>'
$azSubs = Get-AzSubscription

foreach ( $azSub in $azSubs ) {
    Set-AzContext -Subscription $azSub | Out-Null
    $azSubName = $azSub.Name

    $azNsgs = Get-AzNetworkSecurityGroup 
    
    foreach ( $azNsg in $azNsgs ) {
        # Export custom rules
        Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $azNsg | `
            Select-Object @{label = 'NSG Name'; expression = { $azNsg.Name } }, `
            @{label = 'NSG Location'; expression = { $azNsg.Location } }, `
            @{label = 'Rule Name'; expression = { $_.Name } }, `
            @{label = 'Source'; expression = { $_.SourceAddressPrefix } }, `
            @{label = 'Source Application Security Group'; expression = { $_.SourceApplicationSecurityGroups.id.Split('/')[-1] } },
            @{label = 'Source Port Range'; expression = { $_.SourcePortRange } }, Access, Priority, Direction, `
            @{label = 'Destination'; expression = { $_.DestinationAddressPrefix } }, `
            @{label = 'Destination Application Security Group'; expression = { $_.DestinationApplicationSecurityGroups.id.Split('/')[-1] } }, `
            @{label = 'Destination Port Range'; expression = { $_.DestinationPortRange } }, `
            @{label = 'Resource Group Name'; expression = { $azNsg.ResourceGroupName } } | `
            Export-Csv -Path "/home/ghansham_mahajan/$azSubName-nsg-rules.csv" -NoTypeInformation -Append -force
        
        # Export default rules
        Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $azNsg -Defaultrules | `
            Select-Object @{label = 'NSG Name'; expression = { $azNsg.Name } }, `
            @{label = 'NSG Location'; expression = { $azNsg.Location } }, `
            @{label = 'Rule Name'; expression = { $_.Name } }, `
            @{label = 'Source'; expression = { $_.SourceAddressPrefix } }, `
            @{label = 'Source Port Range'; expression = { $_.SourcePortRange } }, Access, Priority, Direction, `
            @{label = 'Destination'; expression = { $_.DestinationAddressPrefix } }, `
            @{label = 'Destination Port Range'; expression = { $_.DestinationPortRange } }, `
            @{label = 'Resource Group Name'; expression = { $azNsg.ResourceGroupName } } | `
            Export-Csv -Path "/home/ghansham_mahajan/$azSubName-nsg-rules.csv" -NoTypeInformation -Append -force
            # Or you can use the following option to export to a single CSV file and to a local folder on your machine
            # Export-Csv -Path "/home/ghansham_mahajan/Azure-nsg-rules.csv" -NoTypeInformation -Append -force
      
    }    
}
