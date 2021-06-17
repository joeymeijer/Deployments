rename-computer -newname (read-host -p "Nieuwe Computernaam")

$bitlockervolumestatus = (Get-Bitlockervolume -mountpoint "C:").VolumeStatus

write-host "bitlocker is $bitlockervolumestatus"

if ($bitlockervolumestatus -ne "FullyDecrypted") {
    #backup bitlockerkey
    $bitlockerrecovery = (get-bitlockervolume).keyprotector | where-object {$_.keyprotectortype -eq "RecoveryPassword"}
    $bitinfo = "
    Device                      = $(hostname)
    Bitlocker Recovery ID       = $($bitlockerrecovery.keyprotectorid)
    Bitlocker Recovery Password = $($bitlockerrecovery.RecoveryPassword) " 

    write-host $bitinfo
    write-host "Info is copied to clipboard to store somewhere safe"
    $bitinfo | clip.exe
    

} else {
    write-warning "Bitlocker is not activated! activate it manually and back-up the key"
}

do {
    $printerinstall = read-host "Do you want to install the printer? (Y/N) "
} until ($printerinstall -eq "Y" -or $printerinstall -eq "N")

if ($printerinstall -eq "Y" ) {
    write-host "going to launch printer install script"
    Invoke-expression (invoke-webrequest -uri "https://raw.githubusercontent.com/Joeym0180/Deploy/main/Shypple/Printers.ps1" -usebasicparsing).Content

} elseif ($printerinstall -eq "N") {
    write-host "Skipping printer installation"
}


