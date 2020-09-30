# Ed-Fi Sample Data Time Travel Script
These scripts were made possible thanks to the Michael and Susan Dell Foundation.

## Description

This very simple SQL script updates the Populated Template of any MS SQL ODS database to the most recent school year and dates related to it.


## Prerequisites
* SSMS Sql Server Manangement Studio
* An Ed-Fi ODS Populated Template Database


## Setup Instructions

**1)** Open SSMS
From the **Windows Menu**, search for **PowerShell**, right click on it, and select **Run as Administrator**
<br/><img src="img/powershell1.png" width="600" >

**2)** Run the automated installer by pasting this command in to the PowerShell window:
> Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://github.com/Ed-Fi-Exchange-OSS/Ed-Fi-MetabaseChronicAbsenteeismQuickStart/raw/main/install.ps1'))


## Legal Information

Copyright (c) 2020 Ed-Fi Alliance, LLC and contributors.

Licensed under the [Apache License, Version 2.0](LICENSE) (the "License").

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
