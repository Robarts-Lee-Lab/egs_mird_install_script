------------------------------------------------------------------------------------------------------------------------------
Introduction
An easy to use bash script for installing egs_mird and all dependencies EGSnrc and egs_brachy on a WSL Ubuntu bash terminal.
------------------------------------------------------------------------------------------------------------------------------
Preinstall requirements
These commands are how to fetch the essential and bonus build packages before running the script
Update package listings:
> sudo apt-get update -y

Install essential EGSnrc compilers:
> sudo apt-get install build-essential git gfortran zlib1g-dev

Install bonus libraries for DICOM and egs_view codes:
> sudo apt-get qtdeclarative5-dev qttools5-dev

Install additional languages that could be useful:
> sudo apt-get perl python3 

Change the atd service to boot with WSL, so as not to have to start it manually for parallel submission:
> sudo update-rc.d atd defaults
------------------------------------------------------------------------------------------------------------------------------
Install Options
To install EGSnrc using the develop branch distribution (instead of the master branch which is updated annually)
> develop=1

To not install DICOM tools after completing the egs_mird install
> noDICOM=1
------------------------------------------------------------------------------------------------------------------------------
