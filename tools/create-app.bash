#!/bin/bash

### Parameters ###

OUTPUT_DIRECTORY=$1
ASSETS_DIRECTORY=$2
SPLASH_BACKGROUND_COLOR=$3
KEYSTORE_PATH=$4
KEYSTORE_PASS=$5
KEYSTORE_ALIAS=$6
KEYSTORE_ALIAS_PASS=$7
CONFIGURATION_FILE=$8
GOOGLE_SERVICES_PATH=$9

### Script path and directory ###

FULL_PATH=$(realpath $0)
DIRECTORY_PATH=$(dirname $FULL_PATH)

### Initial configuration ###

cp $GOOGLE_SERVICES_PATH $DIRECTORY_PATH/../app/App_Resources/Android/

# Parse json configuration file to string
STRINGIFIED_CONFIGURATION=$(jq '. | tostring' $CONFIGURATION_FILE)

APP_ID=$(jq '.client[0].client_info.android_client_info.package_name | tostring' $GOOGLE_SERVICES_PATH | tr -d "\"")

sed -i s/org.camba.radio/$APP_ID/g $DIRECTORY_PATH/../app/App_Resources/Android/app.gradle
sed -i s/org.camba.radio/$APP_ID/g $DIRECTORY_PATH/../package.json

### Assets ###

# Place logo in the assets directory
cp $ASSETS_DIRECTORY/logo.png $DIRECTORY_PATH/../app/assets/images/

# Generate splash screen
tns resources generate splashes $ASSETS_DIRECTORY/splash.png --background $SPLASH_BACKGROUND_COLOR

# Generate app icon
tns resources generate icons $ASSETS_DIRECTORY/icon.png

### Build ###

# Generate a .aab file
tns build android --bundle --release --env.customization=$STRINGIFIED_CONFIGURATION --env.appId=$APP_ID --compileSdk 28 --key-store-path $KEYSTORE_PATH --key-store-password $KEYSTORE_PASS --key-store-alias $KEYSTORE_ALIAS --key-store-alias-password $KEYSTORE_ALIAS_PASS --aab --copy-to $OUTPUT_DIRECTORY

sed -i s/$APP_ID/org.camba.radio/g $DIRECTORY_PATH/../app/App_Resources/Android/app.gradle
sed -i s/$APP_ID/org.camba.radio/g $DIRECTORY_PATH/../package.json
