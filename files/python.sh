#!/bin/bash

# Making python 3.10 (needed for last openwrt versions)
wget https://www.python.org/ftp/python/3.10.0/Python-3.10.0.tgz
tar -xf Python-3.10.*.tgz
cd Python-3.10.*/
./configure --enable-optimizations
make -j$((CORES))
make altinstall