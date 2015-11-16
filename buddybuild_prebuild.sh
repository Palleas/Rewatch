#!//usr/bin/env bash

printenv

if [[ -z "$BetaseriesAPIKey" ]]; then
	echo "BetaseriesAPIKey is not defined!"
	exit 1
fi

if [[ -z "$BetaseriesAPISecret" ]]; then
	echo "BetaseriesAPISecret is not defined!"
	exit 1
fi

if [[ -z "$$MixpanelAPIKey" ]]; then
	echo "$MixpanelAPIKey is not defined: setting empty key"
	MixpanelAPIKey="Mixpanel"
fi

if [[ -z "$CRASHLYTICS_BUILD_SECRET" ]]; then
	echo "CRASHLYTICS_BUILD_SECRET is not defined!"
	exit 1
fi

if [[ -z "$CRASHLYTICS_API_KEY" ]]; then
	echo "CRASHLYTICS_API_KEY is not defined!"
	exit 1
fi

echo "Setting values to \`Keys.plist\` file"
/usr/libexec/PlistBuddy -c "Add BetaseriesAPIKey String $BetaseriesAPIKey" Rewatch/Resources/Keys.plist
/usr/libexec/PlistBuddy -c "Add BetaseriesAPISecret String $BetaseriesAPISecret" Rewatch/Resources/Keys.plist
/usr/libexec/PlistBuddy -c "Add MixpanelAPIKey String $MixpanelAPIKey" Rewatch/Resources/Keys.plist

echo "Setting values to \`xcconfig\` file"
echo "CRASHLYTICS_BUILD_SECRET = $CRASHLYTICS_BUILD_SECRET" >> Rewatch/Resources/Rewatch.xcconfig
echo "CRASHLYTICS_API_KEY = $CRASHLYTICS_API_KEY" >> Rewatch/Resources/Rewatch.xcconfig