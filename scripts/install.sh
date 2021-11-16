#!/usr/bin/env zsh 

are_you_sure()
{
  read -q "REPLY?Install ? "
  printf "\n"

  if [ "$REPLY" = "n" ]; then
    exit
  fi	  
}

remove_ssh_key()
{
  ssh-keygen -f "$HOME/.ssh/known_hosts" -R "$1" 2> /dev/null
}

remove_ssh_keys()
{
  echo "Removing ssh known hosts..."

  remove_ssh_key "192.168.2.101"
  remove_ssh_key "192.168.2.102"
  remove_ssh_key "192.168.2.103"

  remove_ssh_key "192.168.2.104"
  remove_ssh_key "192.168.2.105"
  remove_ssh_key "192.168.2.106"

  remove_ssh_key "192.168.2.110"

  remove_ssh_key "okd4-control-plane-1"
  remove_ssh_key "okd4-control-plane-2"
  remove_ssh_key "okd4-control-plane-3"

  remove_ssh_key "okd4-compute-1"
  remove_ssh_key "okd4-compute-2"
  remove_ssh_key "okd4-compute-2"

  remove_ssh_key "okd4-bootstrap"
}

okd_wait_for_bootstrap_complete()
{
  openshift-install --dir=install_dir/ wait-for bootstrap-complete --log-level=info
}

coreos_installer()
{
  docker run --privileged --pull=always --rm --mount type=bind,source=$PWD,target=/data -w /data \
	        quay.io/coreos/coreos-installer:release "$@"
}

butane()
{
  docker run --privileged --pull=always --rm --mount type=bind,source=$PWD,target=/data -w /data \
	        quay.io/coreos/butane:release "$@"
}

download_iso()
{
  coreos_installer download -s stable -p metal -f iso --directory "$1"
}


download_xz()
{
  coreos_installer download -s stable -p metal -f raw.xz --directory "$1"
  pushd . ; cd "$1"
  rm -f fcos.raw.xz fcos.raw.xz.sig
  ln -s fedora-coreos-*-metal.x86_64.raw.xz fcos.raw.xz
  ln -s fedora-coreos-*-metal.x86_64.raw.xz.sig fcos.raw.xz.sig
  popd
}

if [[ ! -a install-config.yaml ]]; then
  echo "File install-config.yaml not found"
  exit 255
fi

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
rm -rf $INSTALL_DIR ; mkdir -p $INSTALL_DIR

echo "Create release directory"
mkdir -p $RELEASE_DIR 

echo "Download iso file"
download_iso $RELEASE_DIR

echo "Create ignition files"
rm -f install-{bootstrap,master,worker}.ign
butane install-bootstrap.yaml -o install-bootstrap.ign
butane install-master.yaml -o install-master.ign
butane install-worker.yaml -o install-worker.ign

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

sudo cp $RELEASE_DIR/fcos.raw.xz     $OKD4_DIR
sudo cp $RELEASE_DIR/fcos.raw.xz.sig $OKD4_DIR

sudo cp -R $INSTALL_DIR/* $OKD4_DIR

sudo chown -R www-data:root $OKD4_DIR
sudo chmod -R 755 $OKD4_DIR

remove_ssh_keys

echo "Testing..."
curl localhost:8080/okd4/metadata.json

#okd_wait_for_bootstrap_complete

# Login to the cluster and approve CSRs
