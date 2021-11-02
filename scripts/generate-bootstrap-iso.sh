#!/usr/bin/env zsh 

coreos_installer()
{
  docker run --privileged --pull=always --rm --mount type=bind,source=$PWD,target=/data -w /data \
	quay.io/coreos/coreos-installer:release $@ 
}

butane()
{
  docker run --privileged --pull=always --rm --mount type=bind,source=$PWD,target=/data -w /data \
	quay.io/coreos/butane:release $@ 
}

ISO_DEST_DIR=/iso/
RELEASE_DIR=release/

butane install-bootstrap.yaml -o install-bootstrap.ign

rm -f $RELEASE_DIR/fcos-bootstrap.iso
coreos_installer iso ignition embed -i install-bootstrap.ign $RELEASE_DIR/fedora-coreos-*-live.x86_64.iso -o $RELEASE_DIR/fcos-bootstrap.iso

sudo chown $USER $RELEASE_DIR/*
cp $RELEASE_DIR/fcos-bootstrap.iso $ISO_DEST_DIR
chmod 444 $RELEASE_DIR/fcos-{bootstrap,master,worker}.iso
