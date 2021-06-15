$tempdir = "C:\Temp"

function get-SHPdrivers {
    # define vars
    $driverdir = "$($tempdir)\drivers"
    $downloadurl = "https://www.kyoceradocumentsolutions.nl/content/download-center/nl/drivers/all/KX_Universal_Printer_Driver_zip.download.zip"
    new-item -ItemType Directory -path $driverdir -Force -ErrorAction SilentlyContinue | out-null
    $downloadzip = "$($driverdir)\KX_Universal_Printer_Driver_zip.download.zip"
    #end define vars

    #downloading drivers
    try {
        write-host -object "Downloading driverfiles... " -NoNewline
        Invoke-WebRequest -uri $downloadurl -OutFile $downloadzip -ErrorAction Stop
        if ((test-path -PathType leaf -path $downloadzip) -eq $true) {
            write-host "Done" -ForegroundColor Green
            write-host "Expanding zipfile to install Driver"
            Expand-Archive -Path $downloadzip -DestinationPath $driverdir -Force -ErrorAction SilentlyContinue
            Remove-Item -Force -Path $downloadzip
        } else {
            write-host "Failed, could not validate if drivers are downloaded" -ForegroundColor Red
        }
    }
    catch {
        Write-Warning "$_.ErrorDetails"
    }
    #end downloading drivers

    #installing drivers
    Get-ChildItem $driverdir -Recurse -Filter "*.inf" | 
    ForEach-Object { 
            pnputil.exe /add-driver $($_.FullName) /install
            write-host "add-driver $($_.FullName)"
    }

}

function add-SHPprinters {
    add-printerport -name "SHPPRN001port" -printerhostaddress "10.16.6.50"
    add-printerdriver "Kyocera TASKalfa 2553ci KX"
    add-printer -name "SHPPRN001" -drivername "Kyocera TASKalfa 2553ci KX" -Port "SHPPRN001port"

}


#check if printer is installed

try {
    get-printerdriver -name "Kyocera TASKalfa 2553ci KX" -erroraction stop
}
catch {
    write-warning "printerdriver not found, downloading and installing drivers"
    get-SHPdrivers
}

try {
     get-printer -name "SHPPRN001" -erroraction stop
}
catch {
    write-warning "printer niet geinstalleerd, printer toevoegen"
    add-SHPprinters
}