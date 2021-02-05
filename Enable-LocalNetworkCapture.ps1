[CmdletBinding()]
Param ()
    BEGIN {
        #Requires -RunAsAdministrator
        $VerbosePreference = "Continue"
        $TempPath = ("{0}\NetMon" -f $env:TEMP)
        $NetMonDownload = ("{0}\NM34_x64.exe" -f $TempPath)
    }
    PROCESS {
        If (Test-Path -Path "C:\Program Files\Microsoft Network Monitor 3\nmcap.exe") { Write-Verbose ("Network Monitor is installed") }
        Else {
            Write-Verbose ("Downloading Microsoft Network Monitor 3.4")
            If (Test-Path -Path $TempPath) {
                (New-Object System.Net.WebClient).DownloadFile("",$NetMonDownload)
            }
            Else {
                New-Item -Path $TempPath -ItemType Directory | Out-Null
                (New-Object System.Net.WebClient).DownloadFile("",$NetMonDownload)
            }

            If (Test-Path -Path $NetMonDownload) {
                Write-Verbose ("Extracting package")
                & "$NetMonDownload /C /T:$TempPath"
                If (Test-Path -Path ("{0\nmsetup.vbs" -f $TempPath)) {
                    Write-Verbose ("Installing package")
                    Invoke-Expression -Command ("{0}\nmsetup.vbs /q" -f $TempPath)

                    If (Test-Path -Path "C:\Program Files\Microsoft Network Monitor 3\nmcap.exe") { Write-Verbose ("Network Monitor successfully installed") }
                }
            }
            Else {
                Write-Warning ("Microsoft Network Monitor 3.4 was not downloaded")
            }
        }

        Write-Verbose ("Creating folders and fetching configuration files and scripts")
        New-Item -Path "C:\Windows\Utilities\NetworkTracing\Logs" -ItemType Directory -Force | Out-Null
        (New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/msft-jasonparker/NetMonTracing/main/NetMonCapture.xml","C:\Windows\Utilities\NetworkTracing\NetMonCapture.xml")
        (New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/msft-jasonparker/NetMonTracing/main/NetMonCleanUp.xml","C:\Windows\Utilities\NetworkTracing\NetMonCleanUp.xml")
        (New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/msft-jasonparker/NetMonTracing/main/NetMonCleanUp.ps1","C:\Windows\Utilities\NetworkTracing\NetMonCleanUp.ps1")

        & SchTasks.exe /QUERY /TN '\Microsoft\Windows\NetTrace\NetMonCaptures' *>null
        If ($LASTEXITCODE -eq 1) {
            Write-Verbose ("Creating NetMon Capture Scheduled Task")
            & SchTasks.exe /CREATE /TN '\Microsoft\Windows\NetTrace\NetMonCaptures' /XML C:\Windows\Utilities\NetworkTracing\NetMonCapture.xml *>null
            If ($LASTEXITCODE -eq 0) { & SchTasks.exe /RUN /TN '\Microsoft\Windows\NetTrace\NetMonCaptures' *>null }
            Else { Write-Warning ("Failed to create NetMonCapture Scheduled Task") }
        }
        Else { Write-Warning ("NetMonCapture Scheduled Task already exists") }

        & SchTasks.exe /QUERY /TN '\Microsoft\Windows\NetTrace\NetMonCleanUp' *>null
        If ($LASTEXITCODE -eq 1) {
            Write-Verbose ("Creating NetMon Clean Up Scheduled Task")
            & SchTasks.exe /CREATE /TN '\Microsoft\Windows\NetTrace\NetMonCleanUp' /XML C:\Windows\Utilities\NetworkTracing\NetMonCleanUp.xml *>null
            If ($LASTEXITCODE -eq 0) { & SchTasks.exe /RUN /TN '\Microsoft\Windows\NetTrace\NetMonCleanUp' *>null }
            Else { Write-Warning ("Failed to create NetMonCleanUp Scheduled Task") }
        }
        Else { Write-Warning ("NetMonCleanUp Scheduled Task already exists") }
    }
    END { $VerbosePreference = "SilentlyContinue" }