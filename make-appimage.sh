#!/bin/sh

set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook:fix-namespaces.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export APPNAME=Cursor
export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=1
export DEPLOY_PIPEWIRE=1
export OPTIMIZE_LAUNCH=1

# Deploy dependencies
quick-sharun  \
	./AppDir/bin/*             \
	/usr/bin/hostname          \
	/usr/lib/libnss*           \
	/usr/lib/libsoftokn3.so    \
	/usr/lib/libfreeblpriv3.so \
	/usr/lib/pkcs11/*

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --test ./dist/*.AppImage
