[CmdletBinding()]
Param ()
    BEGIN {
        #Requires -RunAsAdministrator
        $CurrentDirectory = Get-Location
        $TempPath = ("{0}\NetMon" -f $env:TEMP)
        $NetMonDownload = ("{0}\NM34_x64.exe" -f $TempPath)
    }
    PROCESS {
        If (Test-Path -Path "C:\Program Files\Microsoft Network Monitor 3\nmcap.exe") { Write-Host ("Network Monitor is installed") -ForegroundColor Green }
        Else {
            Write-Host ("Downloading Microsoft Network Monitor 3.4") -ForegroundColor Cyan
            If (Test-Path -Path $TempPath) {
                (New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/7/1/0/7105C7FF-768E-4472-AFD5-F29108D1E383/NM34_x64.exe",$NetMonDownload)
            }
            Else {
                New-Item -Path $TempPath -ItemType Directory | Out-Null
                (New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/7/1/0/7105C7FF-768E-4472-AFD5-F29108D1E383/NM34_x64.exe",$NetMonDownload)
            }

            If (Test-Path -Path $NetMonDownload) {
                Write-Host ("Installing package") -ForegroundColor Cyan -NoNewline
                Set-Location -Path $TempPath
                & .\NM34_x64.exe /Q
                For ($i=0;$i -lt 15;$i++) {
                    Write-Host "." -ForegroundColor Cyan -NoNewline
                    Start-Sleep -Milliseconds 999
                }
                If (Test-Path -Path "C:\Program Files\Microsoft Network Monitor 3\nmcap.exe") {
                    Write-Host ("Done!") -ForegroundColor Green
                    Write-Host ("Network Monitor successfully installed") -ForegroundColor Green
                }
                Else {
                    Write-Warning ("Microsoft Network Monitor 3.4 - NOT INSTALLED!")
                    Exit
                }
            }
            Else {
                Write-Warning ("Microsoft Network Monitor 3.4 was not downloaded")
            }
        }

        Write-Host ("Creating folders and fetching configuration files and scripts") -ForegroundColor Cyan
        New-Item -Path "C:\Windows\Utilities\NetworkTracing\Logs" -ItemType Directory -Force | Out-Null
        (New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/msft-jasonparker/NetMonTracing/main/NetMonCapture.xml","C:\Windows\Utilities\NetworkTracing\NetMonCapture.xml")
        (New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/msft-jasonparker/NetMonTracing/main/NetMonCleanUp.xml","C:\Windows\Utilities\NetworkTracing\NetMonCleanUp.xml")
        (New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/msft-jasonparker/NetMonTracing/main/NetMonCleanUp.ps1","C:\Windows\Utilities\NetworkTracing\NetMonCleanUp.ps1")

        & SchTasks.exe /QUERY /TN '\Microsoft\Windows\NetTrace\NetMonCaptures' *>null
        If ($LASTEXITCODE -eq 1) {
            Write-Host ("Creating NetMon Capture Scheduled Task") -ForegroundColor Cyan
            & SchTasks.exe /CREATE /TN '\Microsoft\Windows\NetTrace\NetMonCaptures' /XML C:\Windows\Utilities\NetworkTracing\NetMonCapture.xml *>null
            If ($LASTEXITCODE -eq 0) { & SchTasks.exe /RUN /TN '\Microsoft\Windows\NetTrace\NetMonCaptures' *>null }
            Else { Write-Warning ("Failed to create NetMonCapture Scheduled Task") }
        }
        Else { Write-Host ("NetMonCapture Scheduled Task already exists") -ForegroundColor Green }

        & SchTasks.exe /QUERY /TN '\Microsoft\Windows\NetTrace\NetMonCleanUp' *>null
        If ($LASTEXITCODE -eq 1) {
            Write-Host ("Creating NetMon Clean Up Scheduled Task") -ForegroundColor Cyan
            & SchTasks.exe /CREATE /TN '\Microsoft\Windows\NetTrace\NetMonCleanUp' /XML C:\Windows\Utilities\NetworkTracing\NetMonCleanUp.xml *>null
            If ($LASTEXITCODE -eq 0) { & SchTasks.exe /RUN /TN '\Microsoft\Windows\NetTrace\NetMonCleanUp' *>null }
            Else { Write-Warning ("Failed to create NetMonCleanUp Scheduled Task") }
        }
        Else { Write-Host ("NetMonCleanUp Scheduled Task already exists") -ForegroundColor Green }
    }
    END { Set-Location $CurrentDirectory }