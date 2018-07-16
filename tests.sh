#!/bin/bash

OS_NAME=$1
OS_VERSION=$2

export DEBIAN_FRONTEND="noninteractive"

apt-get -qq update || exit 1
apt-get install -y --no-install-recommends checkinstall cmake libgmp10 libmpc3 libmpfr6 || exit 1

echo "deb [trusted=yes] http://dl.bintray.com/hermitcore/ubuntu bionic main" >> /etc/apt/sources.list
apt-get -qq update || exit 1
apt-get install -y --allow-unauthenticated binutils-hermit gcc-hermit-rs newlib-hermit-rs pte-hermit-rs || exit 1
export PATH=/opt/hermit/bin:$PATH

mkdir build
cd build

cmake -DCMAKE_C_COMPILER=x86_64-hermit-gcc \
      -DCMAKE_CXX_COMPILER=x86_64-hermit-g++ \
      -DCMAKE_INSTALL_PREFIX=/opt/hermit/x86_64-hermit \
      -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
      -DHERMIT=1 \
      -DLIBOMP_ARCH=x86_64 \
      -DLIBOMP_ENABLE_SHARED=OFF \
      -DLIBOMP_FORTRAN_MODULES=OFF \
      -DLIBOMP_OMPT_SUPPORT=OFF \
      -DOPENMP_ENABLE_LIBOMPTARGET=OFF \
      .. \
      || exit 1

make -j2 || exit 1
checkinstall -D -y --exclude=build --pkggroup=main --maintainer=stefan@eonerc.rwth-aachen.de --pkgsource=https://hermitcore.org --pkgname=libomp-hermit-rs --pkgversion=5.0 --conflicts=libomp-hermit --pkglicense=MIT make install || exit 1

cd ..
mkdir -p tmp
dpkg-deb -R build/libomp-hermit-rs_5.0-1_amd64.deb tmp
rm -f build/libomp-hermit-rs_5.0-1_amd64.deb
