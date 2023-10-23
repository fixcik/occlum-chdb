#! /bin/bash

set +ex 

export CCFLAGS="-fPIC -pie -Wl"
export RUSTFLAGS="-C target-feature=-crt-static"

wget https://github.com/metrico/libchdb/releases/latest/download/libchdb.zip
unzip libchdb.zip
mv libchdb.so /usr/lib/libchdb.so

cargo build -r

rm -rf instance
occlum new instance 
cd instance/
rm -rf image Occlum.json
cp ../Occlum.json .
copy_bom -f ../bom.yaml --root image --include-dir /opt/occlum/etc/template;
occlum build
occlum package --debug
