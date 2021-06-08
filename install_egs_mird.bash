#!/bin/bash

# These commands are how to fetch the essential and bonus build packages

# Update package listings:
# sudo apt-get update -y

# Install essential EGSnrc compilers
# sudo apt-get install build-essential git gfortran zlib1g-dev

# Install bonus libraries for DICOM and egs_view codes
# sudo apt-get qtdeclarative5-dev qttools5-dev

# Install additional languages that could be useful
# sudo apt-get perl python3 

# Change the atd service to boot with WSL, so as not to have to start it manually for parallel submission
# sudo update-rc.d atd defaults

# Initial variables
getDevelop=0
noDICOM=0

# Options

# To install EGSnrc using the develop branch distribution (instead of the master branch which is updated annually)
# develop=1

# To not install DICOM tools after completing the egs_mird install
# noDICOM=1

# Get input variables
for i in "$@"; do
    case "$i" in
		develop=*)
		getDevelop="${i#*=}"
		shift
		;;
		skipDICOM=*)
		noDICOM="${i#*=}"
		shift
		;;
		*)
		echo "Unknown parameter, ignoring..."
		;;
    esac
done

# Get EGSnrc
git clone https://github.com/nrc-cnrc/EGSnrc
cd EGSnrc/
if [ $getDevelop -eq 1 ]; then
	git checkout origin/develop
fi
cd ../

# Get egs_mird and needed libraries
git clone https://github.com/MartinMartinov/egs_mird

# Move libraries to correct locations, add internal source to cpp Makefile
cp egs_mird/egs_mird/ EGSnrc/HEN_HOUSE/user_codes/ -rf
cp egs_mird/egs_internal_source/ EGSnrc/HEN_HOUSE/egs++/sources/ -rf
cp egs_mird/egs_radionuclide_source/egs_radionuclide_source.* EGSnrc/HEN_HOUSE/egs++/sources/egs_radionuclide_source/ -rf
rm egs_mird -rf
sed -i 's|source_libs = |source_libs = egs_internal_source |' EGSnrc/HEN_HOUSE/egs++/Makefile
sed -i 's|$prog -j12|$prog|' EGSnrc/HEN_HOUSE/scripts/configure

# Get original egs_brachy libraries
git clone https://github.com/clrp-code/EGSnrc_with_egs_brachy

# Move libraries to correct locations, add internal source to cpp Makefile
cp EGSnrc_with_egs_brachy/HEN_HOUSE/egs++/geometry/egs_glib/* EGSnrc/HEN_HOUSE/egs++/geometry/egs_glib/ -rf
cp EGSnrc_with_egs_brachy/HEN_HOUSE/egs++/geometry/egs_autoenvelope/* EGSnrc/HEN_HOUSE/egs++/geometry/egs_autoenvelope/ -rf
rm EGSnrc_with_egs_brachy -rf

# Install EGSnrc with egs_mird
cd EGSnrc/HEN_HOUSE/scripts/
./configure #5 enters, 4 enters, 2 enters, yes then enter, 2 enters, 2 enter, egs_mird then enter
cd ../../../

# Add .bashrc variables
echo "" >> ~/.bashrc
echo "# EGSNRC Variables" >> ~/.bashrc
echo "export EGS_HOME=$PWD/EGSnrc/egs_home/" >> ~/.bashrc
echo "export EGS_CONFIG=$PWD/EGSnrc/HEN_HOUSE/specs/linux.conf" >> ~/.bashrc
echo "source $PWD/EGSnrc/HEN_HOUSE/scripts/egsnrc_bashrc_additions" >> ~/.bashrc
export EGS_HOME=$PWD/EGSnrc/egs_home/
export EGS_CONFIG=$PWD/EGSnrc/HEN_HOUSE/specs/linux.conf
source $PWD/EGSnrc/HEN_HOUSE/scripts/egsnrc_bashrc_additions
echo "export EGS_BATCH_SYSTEM=at" >> ~/.bashrc
EGSnrc/HEN_HOUSE/scripts/finalize_egs_foruser

# Compile egs_view
cd EGSnrc/HEN_HOUSE/egs++/view/
make Makefile_linux
make
cd ../../../../

# Get & install DICOM tools
if [ $noDICOM -eq 1 ]; then
	exit
fi

git clone https://github.com/MartinMartinov/DICOM_tools

cd DICOM_tools/DICOM_from_3ddose/
qmake
make

cd ../DICOM_parser/
qmake
make

cd ../DICOM_to_egsphant/
qmake
make

cd ../DICOM_to_internal_source/
qmake
make
