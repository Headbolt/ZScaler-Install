#!/bin/bash
#
###############################################################################################################################################
#
# ABOUT THIS PROGRAM
#
#	ZScaler-Install.sh
#	https://github.com/Headbolt/ZScaler-Install
#
#   This Script is designed for use in JAMF
#
#   This script was designed to Download a specified version of the ZScalercheck installer and install it
#
###############################################################################################################################################
#
# HISTORY
#
#   Version: 1.0 - 13/09/2022
#
#   - 13/09/2022 - V1.0 - Created by Headbolt, by adapting and improving script by Niladri Datta @ ZScaler 
#							https://community.zscaler.com/t/guide-zscaler-client-connector-deployment-with-jamf-pro-for-macos/16264
#
###############################################################################################################################################
#
#   DEFINE VARIABLES & READ IN PARAMETERS
#
###############################################################################################################################################
#
DownloadURL=$4
CloudName=$5
UserDomain=$6
ScriptName="append prefix here as needed - Deploy - Z Scaler" # Set the name of the script for later logging
#
###############################################################################################################################################
#
#   Checking and Setting Variables Complete
#
###############################################################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
###############################################################################################################################################
#
# Defining Functions
#
###############################################################################################################################################
#
# Section End Function
#
SectionEnd(){
#
/bin/echo # Outputting a Blank Line for Reporting Purposes
/bin/echo  ----------------------------------------------- # Outputting a Dotted Line for Reporting Purposes
/bin/echo # Outputting a Blank Line for Reporting Purposes
#
}
#
###############################################################################################################################################
#
# Script End Function
#
ScriptEnd(){
#
/bin/echo Ending Script '"'$ScriptName'"'
/bin/echo # Outputting a Blank Line for Reporting Purposes
/bin/echo  ----------------------------------------------- # Outputting a Dotted Line for Reporting Purposes
/bin/echo # Outputting a Blank Line for Reporting Purposes
#
exit $ExitCode
#
}
#
###############################################################################################################################################
#
# End Of Function Definition
#
###############################################################################################################################################
# 
# Begin Processing
#
###############################################################################################################################################
#
/bin/echo # Outputting a Blank Line for Reporting Purposes
SectionEnd
#
/bin/echo "`date` - Check for Existence of Pre_Existing Zscaler.zip"
if test -f /tmp/zscaler.zip
	then
		/bin/echo "`date` - /tmp/zscaler.zip Exists !!"
		/bin/echo "`date` - Deleting /tmp/zscaler.zip"
		sudo rm -rf /tmp/zscaler.zip # Cleanup by existing downloaded archive
        /bin/echo # Outputting a Blank Line for Reporting Purposes
fi
#
/bin/echo "`date` - Downloading Requested Version Of Zscaler"
/bin/echo 'Running Command "curl -L -s -k -o  /tmp/zscaler.zip '$DownloadURL' || { /bin/echo ; /bin/echo "`date` Download failed. Exiting" >&2; ExitCode=1; SectionEnd; ScriptEnd; }"'
curl -L -s -k -o  /tmp/zscaler.zip $DownloadURL || { /bin/echo ; /bin/echo "`date` Download failed. Exiting" >&2; ExitCode=1 ;SectionEnd; ScriptEnd; } # Download client zip archive to /tmp
SectionEnd
#
PreExistingBinary='' # Ensuring Variable is blank before checks
PreExistingBinary=$(ls /private/tmp | grep "Zscaler-osx") # Get the installer string
/bin/echo "`date` - Check for Existence of Pre_Existing $PreExistingBinary"
#
if [[ $PreExistingBinary != "" ]]
	then
		/bin/echo "`date` - $PreExistingBinary Exists !!"
		/bin/echo "`date` - Deleting $PreExistingBinary"
		sudo rm -rf /private/tmp/$PreExistingBinary # Cleanup by existing installer
        /bin/echo # Outputting a Blank Line for Reporting Purposes
fi
cd /tmp # Change to Temp folder for file operations
/bin/echo "`date` - Unzipping Zscaler Files"
/bin/echo 'Running Command "sudo unzip -q zscaler.zip || { /bin/echo ;/bin/echo "`date` Cannot decompress dad archive. Exiting" >&2; ExitCode=2; SectionEnd; ScriptEnd; }"'
sudo unzip -q zscaler.zip || { /bin/echo ;/bin/echo "`date` Cannot decompress dad archive. Exiting" >&2; ExitCode=2; SectionEnd; ScriptEnd; } # Unzip Zip into /private/tmp/
/bin/echo # Outputting a Blank Line for Reporting Purposes
/bin/echo "`date` - Removing Zscaler .Zip Download"
/bin/echo /bin/echo 'Running Command "sudo rm -rf zscaler.zip"'
sudo rm -rf zscaler.zip # Cleanup by removing downloaded archive
SectionEnd
#
NewBinary=$(ls /tmp | grep "Zscaler-osx") # Get the installer string
/bin/echo "`date` installing Zscaler"
# Execute the install script. Add additional install options if needed.
/bin/echo 'Running Command "sudo sh /tmp/$NewBinary/Contents/MacOS/installbuilder.sh --cloudName '$CloudName' --unattendedmodeui none --userDomain '$UserDomain' --mode unattended || { /bin/echo ;/bin/echo "`date` Client Connector install failed. Exiting" >&2;  ExitCode=3; SectionEnd; ScriptEnd; }"'
sudo sh /tmp/$NewBinary/Contents/MacOS/installbuilder.sh --cloudName $CloudName --unattendedmodeui none --userDomain $UserDomain --mode unattended || { /bin/echo ;/bin/echo "`date` Client Connector install failed. Exiting" >&2;  ExitCode=3; SectionEnd; ScriptEnd; }
SectionEnd
#
/bin/echo "`date` - Removing Zscaler Installer"
/bin/echo 'Running Command "sudo rm -rf $NewBinary # Cleanup by removing installer"'
sudo rm -rf $NewBinary # Cleanup by removing installer
#
ExitCode=0
ScriptEnd
