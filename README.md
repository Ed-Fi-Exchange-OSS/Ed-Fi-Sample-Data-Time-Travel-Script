# Ed-Fi Sample Data Time Travel Script
These scripts were made possible thanks to the Michael and Susan Dell Foundation.

## Description

This very simple SQL script updates the Populated Template of any MS SQL ODS database to the most recent school year and dates related to it.


## Prerequisites
* SSMS Sql Server Manangement Studio
* An Ed-Fi ODS Populated Template Database


## Setup Instructions

**1)** Open SQL Server Management Studio
From the **File** menu, go to  **Open -> File**, browse for the location of the t-sql script in your computer and open it.
</br> ![File Menu](https://github.com/Ed-Fi-Exchange-OSS/Ed-Fi-Sample-Data-Time-Travel-Script/blob/main/file_menu.png)

**2)** Replace the **[DBName]** with the actual name of the target Database.
</br> ![Db Name](https://github.com/Ed-Fi-Exchange-OSS/Ed-Fi-Sample-Data-Time-Travel-Script/blob/main/dbname.png)

**3)** If you intend to upgrade the ODS data to a year other than current school year, please set the value of **@targetSchoolYear** to the desired School Year
</br> ![Target Year](https://github.com/Ed-Fi-Exchange-OSS/Ed-Fi-Sample-Data-Time-Travel-Script/blob/main/target_year.png)

**4)** Execute the script. 


## Legal Information

Copyright (c) 2020 Ed-Fi Alliance, LLC and contributors.

Licensed under the [Apache License, Version 2.0](LICENSE) (the "License").

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
