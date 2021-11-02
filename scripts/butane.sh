#!/usr/bin/env zsh 

butane()
{
  docker run --privileged --pull=always --rm --mount type=bind,source=$PWD,target=/data -w /data \
	quay.io/coreos/butane:release $@ 
}

butane $@ 

