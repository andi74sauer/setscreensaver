#!/bin/sh
# HARDCODED VALUES ARE SET HERE
startTime="600"
justMain="false"
screenSaverName="Pentland Values"
screenSaverPath="Library/Screen Savers/Pentland Values.saver"
screenSaverType="0"

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER AND, IF SO, ASSIGN
if [ "$4" != "" ] && [ "$startTime" == "" ];then
startTime=$4
fi
if [ "$5" != "" ] && [ "$password" == "" ];then
password=$5
fi
if [ "$6" != "" ] && [ "$passwordDelay" == "" ];then
passwordDelay=$6
fi
##########
# Get the Universally Unique Identifier (UUID)
# ioreg commands found in a comment at http://www.afp548.com/article.php?story=leopard_byhost_changes
#
  # Check if hardware is PPC or early Intel
	if [[ `ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c27-50` == "00000000-0000-1000-8000-" ]]; then
		macUUID=`ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c51-62 | awk {'print tolower()'}`
	# Check if hardware is new Intel
	elif [[ `ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c27-50` != "00000000-0000-1000-8000-" ]]; then
		macUUID=`ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c27-62`
	fi

#
loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
loggedInUserHome=`dscl . -read /Users/$loggedInUser | grep NFSHomeDirectory: | /usr/bin/awk '{print $2}'`

rm -rf "$loggedInUserHome"/Library/Preferences/ByHost/com.apple.screensaver."$macUUID".plist

# Sets time of screen saver to come on.
/usr/libexec/PlistBuddy -c "Add :idleTime integer $startTime" "$loggedInUserHome"/Library/Preferences/ByHost/com.apple.screensaver."$macUUID".plist
/usr/libexec/PlistBuddy -c "Add :mainScreenOnly bool $justMain" "$loggedInUserHome"/Library/Preferences/ByHost/com.apple.screensaver."$macUUID".plist
/usr/libexec/PlistBuddy -c "Add :moduleDict dict" "$loggedInUserHome"/Library/Preferences/ByHost/com.apple.screensaver."$macUUID".plist
/usr/libexec/PlistBuddy -c "Add :moduleDict:moduleName string $screenSaverName" "$loggedInUserHome"/Library/Preferences/ByHost/com.apple.screensaver."$macUUID".plist
/usr/libexec/PlistBuddy -c "Add :moduleDict:path string $screenSaverPath" "$loggedInUserHome"/Library/Preferences/ByHost/com.apple.screensaver."$macUUID".plist
/usr/libexec/PlistBuddy -c "Add :moduleDict:type integer $screenSaverType" "$loggedInUserHome"/Library/Preferences/ByHost/com.apple.screensaver."$macUUID".plist
/usr/libexec/PlistBuddy -c "Add :moduleName string $screenSaverName" "$loggedInUserHome"/Library/Preferences/ByHost/com.apple.screensaver."$macUUID".plist
/usr/libexec/PlistBuddy -c "Add :modulePath string $screenSaverPath" "$loggedInUserHome"/Library/Preferences/ByHost/com.apple.screensaver."$macUUID".plist

#
echo "Set Screen Saver for user: "$loggedInUser"..."
