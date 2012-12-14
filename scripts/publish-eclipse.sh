#!/bin/bash
#

if [ $# -ne 1 ]; then
	echo USAGE: $0 env_file
	exit 1
fi

if [ ! -r "$1" ]; then
	echo "$1" cannot be read
	echo USAGE: $0 env_file
	exit 1
fi

pushd $( dirname $0 ) >/dev/null
SCRIPT_PATH=$(pwd)
popd >/dev/null

. $SCRIPT_PATH/build-functions.sh

. "$1"


cd $BUILD_ROOT

# derived values
gitCache=$( fn-git-cache "$BUILD_ROOT" "$BRANCH" )
aggDir=$( fn-git-dir "$gitCache" "$AGGREGATOR_REPO" )
repositories=$( echo $SCRIPT_PATH/repositories.txt )


if [ -z "$BUILD_ID" ]; then
	BUILD_ID=$(fn-build-id "$BUILD_TYPE" )
fi

buildDirectory=$( fn-build-dir "$BUILD_ROOT" "$BRANCH" "$BUILD_ID" )
basebuilderDir=$( fn-basebuilder-dir "$BUILD_ROOT" "$BRANCH" "$BASEBUILDER_TAG" )

fn-checkout-basebuilder "$basebuilderDir" "$BASEBUILDER_TAG"

launcherJar=$( fn-basebuilder-launcher "$basebuilderDir" )

fn-gather-compile-logs "$BUILD_ID" "$aggDir" "$buildDirectory"
fn-parse-compile-logs "$BUILD_ID" \
"$aggDir"/eclipse.platform.releng.tychoeclipsebuilder/eclipse/helper.xml \
"$buildDirectory" "$launcherJar"

touch $(dirname "$buildDirectory")/directory.txt

fn-publish-eclipse "$BUILD_TYPE" "$BUILD_ID" "$aggDir" "$buildDirectory" "$launcherJar"
