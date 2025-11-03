#!/bin/sh

set -eu
ARCH="$(uname -m)"
DEB_SOURCE="https://cursor.com/download"
EXTRA_PACKAGES="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/get-debloated-pkgs.sh"

echo "Installing dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	base-devel        \
	curl              \
	git               \
	inetutils         \
	libx11            \
	libxrandr         \
	libxss            \
	pulseaudio        \
	pulseaudio-alsa   \
	pipewire-audio    \
	wget              \
	xorg-server-xvfb  \
	zsync

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
wget --retry-connrefused --tries=30 "$EXTRA_PACKAGES" -O ./get-debloated-pkgs.sh
chmod +x ./get-debloated-pkgs.sh
./get-debloated-pkgs.sh --add-common --prefer-nano

echo "Getting Cursor..."
echo "---------------------------------------------------------------"
case "$ARCH" in # they use AMD64 and ARM64 for the deb links
	x86_64)  deb_arch=amd64;;
	aarch64) deb_arch=arm64;;
esac

DEB_LINK=$(
	wget --retry-connrefused --tries=30 "$DEB_SOURCE" -O - \
		| sed 's/[()",{} ]/\n/g'                       \
		| grep -o  "https.*linux.*$deb_arch.*deb"      \
		| head -1
)

wget --retry-connrefused --tries=30 "$DEB_LINK" -O /tmp/cursor.deb
ar xvf /tmp/cursor.deb
tar -xvf ./data.tar.xz
rm -f ./*.xz
mv -v ./usr ./AppDir
mv -v ./AppDir/share/cursor                           ./AppDir/bin
cp -v ./AppDir/share/applications/cursor.desktop      ./AppDir
cp -v ./AppDir/share/pixmaps/co.anysphere.cursor.png  ./AppDir

echo "$DEB_LINK" | awk -F'_' '{print $(NF-1)}' > ~/version

