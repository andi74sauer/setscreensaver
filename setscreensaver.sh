#!/bin/sh
####################################################################################################
#
# This is free and unencumbered software released into the public domain.
# 
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
# 
# In jurisdictions that recognise copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
# 
# For more information, please refer to <http://unlicense.org/>
#
####################################################################################################
#
# More information: http://macmule.com/2010/11/18/how-to-set-osxs-screen-saver-via-script/
#
# GitRepo: https://github.com/macmule/setscreensaver
#
####################################################################################################

###########
# 
# HARDCODED VALUES ARE SET HERE
#
###########

startTime="" 			# Integer - Seconds
justMain=""			# Boolean
screenSaverName=""		# String
screenSaverPath=""		# String
requirePassword=""		# Integer (1 = true, 0 = false)
timeBeforeRequiringPassword=""	# Integer - Seconds

####
# IF RUN AS A SCRIPT IN CASPER, CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER AND, IF SO, ASSIGN
####

if [ "$4" != "" ] && [ "$startTime" == "" ]; then
	startTime=$4
fi

if [ "$5" != "" ] && [ "$justMain" == "" ]; then
	justMain=$5
fi

if [ "$6" != "" ] && [ "$screenSaverName" == "" ]; then
	screenSaverName=$6
fi

if [ "$7" != "" ] && [ "$screenSaverPath" == "" ]; then
	screenSaverPath=$7
fi

if [ "$8" != "" ] && [ "$requirePassword" == "" ]; then
	requirePassword=$8
fi

if [ "$9" != "" ] && [ "$timeBeforeRequiringPassword" == "" ]; then
	timeBeforeRequiringPassword=$9
fi


###########
# 
# Get the Universally Unique Identifier (UUID) for the correct platform
# ioreg commands found in a comment at http://www.afp548.com/article.php?story=leopard_byhost_changes
#
###########

	# Check if hardware is PPC or early Intel
	if [[ `ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c27-50` == "00000000-0000-1000-8000-" ]]; then
		macUUID=`ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c51-62 | awk {'print tolower()'}`
	# Check if hardware is new Intel
	elif [[ `ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c27-50` != "00000000-0000-1000-8000-" ]]; then
		macUUID=`ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c27-62`
	fi

###########

# Get the Username of the currently logged user
loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`

# Query dscl to get the currently logged in users home folder 
loggedInUserHome=`dscl . -read /Users/$loggedInUser | grep NFSHomeDirectory: | /usr/bin/awk '{print $2}'`

# Remove the old screensaver plist, comment out if you only want to amend a part of the plist
rm -rf "$loggedInUserHome"/Library/Preferences/ByHost/com.apple.screensaver."$macUUID".plist

###########
#
# For each variable check to see if it has a value. If it does then write the variables value to the applicable plist in the applicable manner
#
###########

# Variables for the ~/Library/Preferences/ByHost/com.apple.screensaver."$macUUID".plist

if [[ -n $startTime ]]; then
	/usr/libexec/PlistBuddy -c "Add :idleTime integer $startTime" "$loggedInUserHome"/Library/Preferences/ByHost/com.apple.screensaver."$macUUID".plist
fi

if [[ -n $justMain ]]; then
	/usr/libexec/PlistBuddy -c "Add :mainScreenOnly bool $justMain" "$loggedInUserHome"/Library/Preferences/ByHost/com.apple.screensaver."$macUUID".plist
fi

# Make sure the moduleDict dictionary exists
	/usr/libexec/PlistBuddy -c "Add :moduleDict dict" "$loggedInUserHome"/Library/Preferences/ByHost/com.apple.screensaver."$macUUID".plist

if [[ -n $screenSaverName ]]; then
	/usr/libexec/PlistBuddy -c "Add :moduleDict:moduleName string $screenSaverName" "$loggedInUserHome"/Library/Preferences/ByHost/com.apple.screensaver."$macUUID".plist
	/usr/libexec/PlistBuddy -c "Add :moduleName string $screenSaverName" "$loggedInUserHome"/Library/Preferences/ByHost/com.apple.screensaver."$macUUID".plist
fi

if [[ -n $screenSaverPath ]]; then
	/usr/libexec/PlistBuddy -c "Add :moduleDict:path string $screenSaverPath" "$loggedInUserHome"/Library/Preferences/ByHost/com.apple.screensaver."$macUUID".plist
	/usr/libexec/PlistBuddy -c "Add :modulePath string $screenSaverPath" "$loggedInUserHome"/Library/Preferences/ByHost/com.apple.screensaver."$macUUID".plist
fi

# Variables for the ~/Library/Preferences/com.apple.screensaver.plist

if [[ -n $requirePassword ]]; then
	/usr/libexec/PlistBuddy -c "Add :askForPassword integer $startTime" "$loggedInUserHome"/Library/Preferences/com.apple.screensaver.plist
fi

if [[ -n $timeBeforeRequiringPassword ]]; then
	/usr/libexec/PlistBuddy -c "Add :askForPasswordDelay integer $timeBeforeRequiringPassword" "$loggedInUserHome"/Library/Preferences/com.apple.screensaver.plist
fi

#
echo "Set Screen Saver for user: "$loggedInUser"..."
