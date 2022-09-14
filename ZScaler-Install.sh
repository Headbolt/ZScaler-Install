#!/bin/bash
#
###############################################################################################################################################
#
# ABOUT THIS PROGRAM
#
#	ZScaler-Install.sh
#	https://github.com/Headbolt/ZScaler-Install
#
#   This Script is designed for use in JAMF and was designed to Download a specified version of the ZScalercheck installer and install it
#
#	The Following Variables should be defined
#	Variable 4 - Named "Download URL for Client Connector - eg. https://d32a6ru7mhaq0c.cloudfront.net/Zscaler-osx-3.6.1.19-installer.app.zip"
#	Variable 5 - Named "Cloud Name - eg. ZCloud"
#	Variable 6 - Named "User Domain - eg. domain.com - OPTIONAL"
#
###############################################################################################################################################
#
# HISTORY
#
#   Version: 1.0 - 13/09/2022
#
#	13/09/2022 - V1.0 - Created by Headbolt, by adapting download and install commands found in script posted Niladri Datta @ ZScaler 
#			https://community.zscaler.com/t/guide-zscaler-client-connector-deployment-with-jamf-pro-for-macos/16264
#
#	14/09/2022 - NOTE - It would appear these commands were pulled from a script by Harry Richman without credit by Zscaler staff
#			https://github.com/aharon-br/jamf-scripts/blob/master/Download%20and%20Install%20Zscaler%20for%20Jamf.sh
#			This was discovered after posting this solution to a JAMF Nation thread with no marked answer, and without reading
#			the full thread, which Harry Richman posted on shortly after, to highlight this.
#			This note is to aknowledge Harry Richman's initial efforts, and to thank him for it.
#
###############################################################################################################################################
#
#   DEFINE VARIABLES & READ IN PARAMETERS
#
###############################################################################################################################################
#
DownloadURL=$4 # Grab the Download URL for the installer from JAMF variable #4 eg. https://d32a6ru7mhaq0c.cloudfront.net/Zscaler-osx-3.6.1.19-installer.app.zip
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
# Variable Check Function
#
VarCheck(){
#
/bin/echo 'Checking that the required Variables are set' # Check that the required variables are set
/bin/echo # Outputting a Blank Line for Reporting Purposes
#
if [ "${DownloadURL}" == "" ]
	then
		/bin/echo 'DownloadURL undefined.  Please pass the DownloadURL in parameter 4'
        ExitCode=4
		SectionEnd
		ScriptEnd
	else
    	/bin/echo 'DownloadURL Defined as '"$DownloadURL"''
fi
#
/bin/echo # Outputting a Blank Line for Reporting Purposes
if [ "${CloudName}" == "" ]
	then
		/bin/echo 'CloudName undefined.  Please pass the CloudName in parameter 5'
    	ExitCode=4
        SectionEnd
    	ScriptEnd
	else
		/bin/echo 'CloudName Defined as '"$CloudName"''

fi
#
/bin/echo # Outputting a Blank Line for Reporting Purposes
if [ "${UserDomain}" == "" ]
	then
		/bin/echo 'UserDomain undefined, this is not required.'
		/bin/echo 'Proceeding with User Domain empty, if this is requred please pass the UserDomain in parameter 6'
		UserDomainSetting=""
	else
		UserDomainSetting="--userDomain $UserDomain"
		/bin/echo 'UserDomain Defined as '"$UserDomain"''
fi
#
/bin/echo # Outputting a Blank Line for Reporting Purposes
/bin/echo Required Variables appear to be set
#
}
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
VarCheck
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
/bin/echo # Outputting a Blank Line for Reporting Purposes
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
/bin/echo # Outputting a Blank Line for Reporting Purposes
sudo rm -rf zscaler.zip # Cleanup by removing downloaded archive
SectionEnd
#
NewBinary=$(ls /tmp | grep "Zscaler-osx") # Get the installer string
/bin/echo "`date` installing Zscaler"
# Execute the install script. Add additional install options if needed.
/bin/echo 'Running Command "sudo sh /tmp/$NewBinary/Contents/MacOS/installbuilder.sh --cloudName '$CloudName' --unattendedmodeui none '$UserDomainSetting' --mode unattended || { /bin/echo ;/bin/echo "`date` Client Connector install failed. Exiting" >&2;  ExitCode=3; SectionEnd; ScriptEnd; }"'
/bin/echo # Outputting a Blank Line for Reporting Purposes
sudo sh /tmp/$NewBinary/Contents/MacOS/installbuilder.sh --cloudName $CloudName --unattendedmodeui none $UserDomainSetting --mode unattended || { /bin/echo ;/bin/echo "`date` Client Connector install failed. Exiting" >&2;  ExitCode=3; SectionEnd; ScriptEnd; }
SectionEnd
#
/bin/echo "`date` - Removing Zscaler Installer"
/bin/echo 'Running Command "sudo rm -rf $NewBinary # Cleanup by removing installer"'
sudo rm -rf $NewBinary # Cleanup by removing installer
SectionEnd
#
ExitCode=0
ScriptEnd
