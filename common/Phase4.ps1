#-----------------------
# Phase4.ps1
#-----------------------

$ErrorActionPreference='Stop'

try {

    echo "$(date) Phase4.ps1 starting" >> $env:SystemDrive\packer\configure.log
    echo $(date) > "c:\users\public\desktop\Phase4 Start.txt"

    if ($env:LOCAL_CI_INSTALL -eq 1) {
        echo "$(date) Phase4.ps1 Removing administrator Phase4.lnk" >> $env:SystemDrive\packer\configure.log
        Remove-Item "C:\Users\administrator\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Phase4.lnk" -Force -ErrorAction SilentlyContinue

        echo "$(date) Phase4.ps1 quitting on local CI" >> $env:SystemDrive\packer\configure.log
        exit 0
    }

    echo "$(date) Phase4.ps1 Removing jenkins Phase4.lnk" >> $env:SystemDrive\packer\configure.log
    Remove-Item "C:\Users\jenkins\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Phase4.lnk" -Force -ErrorAction SilentlyContinue

    # Add the registry keys to stop reporting as it skew stats
    echo "$(date) Phase4 Adding SQM keys" >> $env:SystemDrive\packer\configure.log
    if (-not (Test-Path "HKCU:Software\Microsoft\SQMClient")) {
        New-Item -Path "HKCU:Software\Microsoft\SQMClient" -Force -ErrorAction SilentlyContinue | Out-Null
    }
    New-ItemProperty -Path "HKCU:Software\Microsoft\SQMClient" -Name "isTest" -Value 1 -PropertyType DWORD -Force -ErrorAction SilentlyContinue | Out-Null
    New-ItemProperty -Path "HKCU:Software\Microsoft\SQMClient" -Name "MSFTInternal" -Value 1 -PropertyType DWORD -Force -ErrorAction SilentlyContinue | Out-Null
    echo "$(date) Phase4 SQM Keys added" >> $env:SystemDrive\packer\configure.log

    # Configure cygwin ssh daemon
    echo "$(date) Phase4.ps1 killing sshd if running..." >> $env:SystemDrive\packer\configure.log
    Start-Process -wait taskkill -ArgumentList "/F /IM sshd.exe" -ErrorAction SilentlyContinue
    echo "$(date) Phase4.ps1 invoking ConfigureSSH.ps1..." >> $env:SystemDrive\packer\configure.log
    . $("$env:SystemDrive\packer\ConfigureSSH.ps1")
}
Catch [Exception] {
    echo "$(date) Phase4.ps1 complete with Error '$_'" >> $env:SystemDrive\packer\configure.log
    echo $(date) > "c:\users\public\desktop\ERROR Phase4.txt"
    exit 1
}
Finally {
    $ErrorActionPreference='SilentlyContinue'
    echo "$(date) Phase4.ps1 finally block" >> $env:SystemDrive\packer\configure.log
    echo $(date) > "c:\users\public\desktop\Phase4 End.txt"
} 