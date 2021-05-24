param (
    [parameter(Mandatory=$true)][string]$SubscriptionName,
    [parameter(Mandatory=$true)][string]$VnetName,
    [parameter(Mandatory=$false)][string]$SubnetSize,
    [parameter(Mandatory=$false)][int]$count = 1

)

#=================function for ip range calculation===========
function Convert-ToNumberRange {

    [CmdletBinding()]

    param (

        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true, HelpMessage='Range of numbers in array.')]

        [int[]]$series

    )

    begin {

        $numberseries = @()

    }

    process {

        $numberseries += $series

    }

    end {

        $numberseries = @($numberseries | Sort-Object | Select-Object -Unique)

        $index = 1

        $initmode = $true

             # Start at the beginning

        $start = $numberseries[0]

            # If we only have a single number in the series, then go ahead and return it

        if ($numberseries.Count -eq 1) {

            return New-Object psobject -Property @{

                'Begin' = $numberseries[0]

                'End' = $numberseries[0]

            }

        }

        do {

            if ($initmode) {

                $initmode = $false

            }

            else {

                # If the current number minus the last number is not exactly 1, then the range has split

                # (so we have a non-contiguous series of numbers like 1,2,3,12,13,14….)

                if (($numberseries[$index] - $numberseries[$index - 1]) -ne 1) {

                    New-Object psobject -Property @{

                        'Begin' = $start

                        'End' = $numberseries[$index-1]

                    }

                    # Reset our starting point and begin again

                    $start = $numberseries[$index]

                    $initmode = $true

                }

            }

            $index++

        } until ($index -eq ($numberseries.length))

           # We should always end up with a result at the end for the last digits

        New-Object psobject -Property @{

            'Begin' = $start

            'End' = $numberseries[$index - 1]

        }

    }

}
#==============Rest of the script=============================
$context = Set-AzContext -subscriptionname $SubscriptionName

$vnet = Get-AzVirtualNetwork -Name $vnetname

$availableips = @()
$usedips = @()
$sublist = @()
$subnetoutput = @()
#Write-Host $SubscriptionName $VnetName
Foreach ($addspace in $vnet.AddressSpace.AddressPrefixes){
$subnets = ""
#get the address space and calculate the total available ip's for the space

#calculate the possible /24 subnets within the address space, this makes scanning for existing and possible subnet space easier
$addspacemask = $addspace.split('/')[1]
$addspacerange = [MATH]::Pow(2,(32 - $addspacemask))
$24s = $addspacerange / 256

#get the first 3 octets from the address space
[int]$baseoct = ($addspace.Split('.')[2])
$snfirst2 = ($addspace.Split('.') | Select-Object -Index 0,1) -join "."


#use the first 2 octets from the address space and then count up by the amount of possible /24s starting at baseoct to create a list of possible subnets within the address space.
for ($i=0; $i -lt $24s; $i++) {
[array]$subnets += $snfirst2+"."+($baseoct + $i)
}

foreach ($subnet in $subnets) { 
if ($subnet) {
    for ($i = 0; $i -lt 256; $i ++) {
        [string]$ip = $subnet+"."+$i
        $availableips = $availableips + $ip
        #$ip
        }
}
}





}

#then do the same thing for each subnet, add their ip's to the $usedips variable

$allocatedsubs = ($vnet.subnets).addressprefix
foreach ($allocatedsub in $allocatedsubs) {

$submask = $allocatedsub.split('/')[1]

#pause



if ($submask -ge 24) {
#Write-Host "Small Range"
#pause

    #do regular small range math


    #calculate how many IP's are used by the subnet
    [int]$subnetrange = [MATH]::Pow(2,(32 - $submask))

    [int]$baseoct = ($allocatedsub.Split('.')[2])

    $snfirst2 = ($allocatedsub.Split('.') | Select-Object -Index 0,1) -join "."

    $subsub = $snfirst2+"."+$baseoct
    $sublist += $subsub

    #get the first IP address and then add the ips used from above
    [int]$startip = ($allocatedsub -split {$_ -eq "." -or $_ -eq "/"})[3]
    [int]$endip = $startip + $subnetrange

        for ($i = $startip; $i -lt $endip; $i ++) {
            [string]$ip = $subsub+"."+$i
            $usedips = $usedips + $ip
            
            }
#$usedips.Count
#pause
}
else {
#do big range math
#Write-Host "Big Range" 
#pause
$subns = @()
    $subrange = [MATH]::Pow(2,(32 - $submask))

    $24s = $subrange / 256

  #get the first 3 octets from the address space

    [int]$baseoct = ($allocatedsub.Split('.')[2])

    $snfirst2 = ($allocatedsub.Split('.') | Select-Object -Index 0,1) -join "."


   #use the first 2 octets from the address space and then count up by the amount of possible /24s starting at baseoct to create a list of possible subnets within the address space.

        for ($i=0; $i -lt $24s; $i++) {
        [array]$subns += $snfirst2+"."+($baseoct + $i)
        #$subns
        }

        foreach ($subsub in $subns) { 
        #$subsub
            for ($i = 0; $i -lt 256; $i ++) {
                [string]$ip = $subsub+"."+$i
                $usedips = $usedips + $ip
                
                }
        #$usedips.Count
        #pause
        $sublist += $subsub
        }



}

}


$availableips = compare-Object $usedips $availableips -passthru 


$sublist = $availableips | foreach-Object {($_.split('.') | Select-Object -Index 0,1,2)  -join "." } | Select-Object -Unique


foreach ($sublet in $sublist) {
    
   
$subletips = ($availableips -match $sublet | foreach-Object {$_.split('.')[3]})

if ($subletips) {
$availableranges = $subletips | Convert-ToNumberRange

foreach ($range in $availableranges) {
$start = $range.begin
$actualips = $range.End - $range.Begin
$maxsubnetsize = 32 - ([MATH]::Floor([MATH]::log($actualips,2)))


$subnetoutput += New-Object psobject -Property @{
'IPCount' = $actualips + 1
'MaxSubnetSize' = $maxsubnetsize
'StartIP' = $start
'EndIP' = $start + $actualips 
'PreFix' = $sublet
}
}
}
}

if ($SubnetSize) {
    $multiple = 256 / [MATH]::Pow(2,(32 - $subnetsize)) 
  

    $increment = 256 / $multiple

    #get valid ranges
    $validrange = ($subnetoutput | Where-Object {($_.IPCount -ge $increment)})[$count - 1]

    #set the first ip, then concat prefix with first ip

    for ($i = 0; $i -le $multiple; $i++) {
     $firstip = $i * $increment
     #write-host $firstip
     #pause
     if (($firstip -ge $validrange.StartIP) -and (($firstip + $increment - 1) -le ($validrange.EndIP))) {
        $validsubnet = New-Object psobject -Property @{
            'cidr' = $validrange.PreFix+"."+$firstip+"/"+$SubnetSize
            }
        $validsubnet 
        return
     }

    }
    
}
else {
    $subnetoutput | ft
}
