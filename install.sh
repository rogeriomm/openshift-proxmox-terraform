#!/usr/bin/env zsh 

are_you_sure()
{
  read -q "REPLY?Install ? "
  echo "\n"

  if [ "$REPLY" = "n" ]; then
    exit
  fi	  
}

remove_ssh_keys()
{
  echo "Removing ssh known hosts..."

  ssh-keygen -f -R "okd4-control-plane-1" 2> /dev/null
  ssh-keygen -f -R "okd4-control-plane-2" 2> /dev/null
  ssh-keygen -f -R "okd4-control-plane-3" 2> /dev/null

  ssh-keygen -f -R "okd4-compute-1" 2> /dev/null
  ssh-keygen -f -R "okd4-compute-2" 2> /dev/null
  ssh-keygen -f -R "okd4-compute-3" 2> /dev/null

  ssh-keygen -f -R "okd4-bootstrap" 2> /dev/null
}

coreos_installer()
{
  docker run --privileged --pull=always --rm --mount type=bind,source=$PWD,target=/data -w /data \
	quay.io/coreos/coreos-installer:release $@ 
}

download_iso()
{
  coreos_installer download -s stable -p metal -f iso --directory $1
}


download_xz()
{
  coreos_installer download -s stable -p metal -f raw.xz --directory $1
  pushd . ; cd $1
  rm -f fcos.raw.xz fcos.raw.xz.sig
  ln -s fedora-coreos-*-metal.x86_64.raw.xz fcos.raw.xz
  ln -s fedora-coreos-*-metal.x86_64.raw.xz.sig fcos.raw.xz.sig
  popd
}


are_you_sure

set -x

INSTALL_DIR=install_dir/
OKD4_DIR=/var/www/html/okd4/
ISO_DEST_DIR=/iso/
RELEASE_DIR=release/

echo "Removing install directory"
rm -rf $INSTALL_DIR 

echo "Removing ISO files"
rm -f $RELEASE_DIR/fcos-{bootstrap,master,worker}.iso
rm -f $ISO_DEST_DIR/fcos-{bootstrap,master,worker}.iso

echo "Create install directory"
mkdir -p $INSTALL_DIR 

echo "Create release directory"
mkdir -p $RELEASE_DIR 

echo "Download iso file"
download_iso $RELEASE_DIR

echo "Change original iso file, add ignition file"
coreos_installer iso ignition embed -i install-bootstrap.ign $RELEASE_DIR/fedora-coreos-*-live.x86_64.iso -o $RELEASE_DIR/fcos-bootstrap.iso
coreos_installer iso ignition embed -i install-master.ign    $RELEASE_DIR/fedora-coreos-*-live.x86_64.iso -o $RELEASE_DIR/fcos-master.iso
coreos_installer iso ignition embed -i install-worker.ign    $RELEASE_DIR/fedora-coreos-*-live.x86_64.iso -o $RELEASE_DIR/fcos-worker.iso

echo "Download raw.xz"
download_xz $RELEASE_DIR 

sudo chown $USER $RELEASE_DIR/*

echo "Copying install config yaml..."
cp install-config.yaml $INSTALL_DIR 

echo "Creting manifests..."
openshift-install create manifests --dir=$INSTALL_DIR
sed -i 's/mastersSchedulable: true/mastersSchedulable: False/' $INSTALL_DIR/manifests/cluster-scheduler-02-config.yml

echo "Creating ignition files..."
openshift-install create ignition-configs --dir=$INSTALL_DIR

echo "Copying apache files"
sudo rm -rf $OKD4_DIR 
sudo mkdir -p $OKD4_DIR

cp $RELEASE_DIR/fcos-bootstrap.iso $ISO_DEST_DIR
cp $RELEASE_DIR/fcos-master.iso    $ISO_DEST_DIR
cp $RELEASE_DIR/fcos-worker.iso    $ISO_DEST_DIR
chmod 444 $RELEASE_DIR/fcos-{bootstrap,master,worker}.iso

sudo cp -R $INSTALL_DIR/* $OKD4_DIR

sudo chown -R www-data:root /var/www/html/okd4
sudo chmod -R 755 /var/www/html/okd4

remove_ssh_keys

echo "Testing..."
curl localhost:8080/okd4/metadata.json
