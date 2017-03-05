#!/bin/bash

set -xe

QT_BASE_DIR=/opt/qt58
export QTDIR=$QT_BASE_DIR
export PATH=$QT_BASE_DIR/bin:$PATH

# clone chigraph
rm -rf /chigraph
cd /
git clone https://github.com/chigraph/chigraph --recursive --depth 1

# acquire linuxdeployqt
cd /
rm -Rf /linuxdeployqt
if [ ! -d AppImageKit ] ; then
  git clone  --depth 1 https://github.com/probonopd/linuxdeployqt.git /linuxdeployqt
fi

cd /linuxdeployqt/
qmake linuxdeployqt.pro
make -j8
cd /


# prepare the appdir
mkdir -p /chigraph.appdir/usr
mkdir -p /chigraph.appdir/usr/lib
cd  /chigraph.appdir/usr
rm -rf lib64 || true
ln -s lib lib64


# build KF5
python3 /chigraph/setup.py
rsync -raP /chigraph/third_party/kf5-release/* /chigraph.appdir/usr/

# build chigraph
cd /chigraph
rm -rf build
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="/chigraph.appdir/usr" -DCMAKE_INSTALL_PREFIX='/usr' -DLLVM_CONFIG='/usr/lib/llvm-4.0/bin/llvm-config' -DCMAKE_CXX_COMPILER=clang++-4.0 -DCMAKE_C_COMPILER=clang-4.0 -DCMAKE_CXX_FLAGS='-std=c++14'
make -j8 DESTDIR=/chigraph.appdir install

# remove pointless stuff
cd /chigraph.appdir/
rm -rf ./usr/include
find . -name '*.a' -exec rm {} \;

cp /chigraph/scripts/appimage/chiggui.desktop /chigraph.appdir/

unset QTDIR # not sure why we do this
/linuxdeployqt/linuxdeployqt/linuxdeployqt /chigraph.appdir/chiggui.dekstop -bundle-non-qt-libs
/linuxdeployqt/linuxdeployqt/linuxdeployqt /chigraph.appdir/chiggui.dekstop -appimage

