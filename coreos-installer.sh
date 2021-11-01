docker run --privileged --pull=always --rm --mount type=bind,source=`pwd`,target=/data -w /data \
	quay.io/coreos/coreos-installer:release $@ 
