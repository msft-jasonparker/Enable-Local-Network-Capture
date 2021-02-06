# Enable Local Network Capture

> *Based on Microsoft Network Monitor 3.4 (deprecated)*
## Overview

There are cases when troubleshooting network related issues where having a local network packet capture is useful. This is especially true when the issue you are troubleshooting is intermittent. Microsoft Network Monitor 3.4, while deprecated and no longer updated, is easy to install, use and configure for automated capturing.

## Contents

Item  |   Description
--- |   ---
Enable-LocalNetworkCapture.ps1  |   This is a single script which will download and install the application and configure the scheduled tasks
NetMonCapture.xml   |   XML file used to create a scheduled task for the packet capture
NetMonCleanUp.xml   |   XML file used to create a scheduled task to run the NetMonCleanUp.ps1 script (prunes the old capture files)
NetMonCleanUp.ps1   |   Script used to clean up capture files older than 3 days

## Getting Started

This is a very easy and straight forward solution. Follow the steps below:

- Clone this repository or download and extract the zip file
- Open PowerShell as an Administrator
- Navigate to the directory where the Enable-LocalNetworkCapture.ps1 file is located
- Run the script!

> **NOTE:**
> 
> *If this is the first time running a script from the Internet, you'll need to update your execution policy*
>
> ``` Set-ExecutionPolicy -ExecutionPolicy ByPass -Scope CurrentUser ```
