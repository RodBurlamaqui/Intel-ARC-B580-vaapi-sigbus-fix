#!/usr/bin/env bash
# Rebuild intel-media-va-driver-non-free with the small-BAR SIGBUS fix.
# Debian 13 (trixie). Produces a .deb in the parent directory.
set -euo pipefail

PKG=intel-media-va-driver-non-free
SRC=intel-media-driver-non-free
PATCH=0003-Fix-SIGBUS-on-xe-small-BAR-systems.patch
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK="${1:-$PWD/build}"

command -v sudo >/dev/null || { echo "sudo required"; exit 1; }

echo "==> Enabling deb-src"
if ! grep -qE '^(deb-src|Types:.*deb-src)' /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
    sudo cp /etc/apt/sources.list.d/debian.sources{,.bak-$(date +%s)}
    sudo sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/debian.sources
    sudo apt-get update -qq
fi

echo "==> Installing build tooling"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq devscripts quilt build-essential

echo "==> Fetching Debian source"
mkdir -p "$WORK" && cd "$WORK"
apt-get source "$PKG"
cd "$SRC"-*/

if grep -q "$PATCH" debian/patches/series 2>/dev/null; then
    echo "==> Patch already present, skipping"
else
    echo "==> Applying $PATCH"
    cp "$HERE/patches/$PATCH" debian/patches/
    echo "$PATCH" >> debian/patches/series
    QUILT_PATCHES=debian/patches quilt push -a
fi

echo "==> Installing build dependencies"
sudo DEBIAN_FRONTEND=noninteractive apt-get build-dep -y -qq "$PKG"

echo "==> Building (this takes a while; ~1800 objects)"
dpkg-buildpackage -b -uc -us -j"$(nproc)"

echo
echo "==> Done. Package(s):"
ls -la ../*.deb
echo
echo "Install with:  sudo apt install ../<file>.deb"
