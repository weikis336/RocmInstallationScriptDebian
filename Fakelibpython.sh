#!/bin/bash
cd /opt/rocmbuild/

sudo tee libpython-fake.equivs << EOF
Section: miscional
Priority: optional URL here; no default>
# Homepage: <enter URL here; no default>
Standards-Version: 3.9.2
Package: libpython3.10-fake
Package: libpython3.10-fake
Version: 3.10.12-1~22.04.3ourname@example.com>
# Maintainer: Your Name <yourname@example.com>es>
# Pre-Depends: <comma-separated list of packages>
Depends: libpython3-stdlibated list of packages>
# Recommends: <comma-separated list of packages>
# Suggests: <comma-separated list of packages>
Provides: libpython3.10rated list of packages>
# Replaces: <comma-separated list of packages>
# Architecture: allof: foreign|same|allowed>
# Multi-Arch: <one of: foreign|same|allowed>L2>
# Copyright: <copyright file; defaults to GPL2>eric changelog>
# Changelog: <changelog file; defaults to a generic changelog>
# Readme: <README.Debian file; defaults to a generic one>for the doc directory>
# Extra-Files: <comma-separated list of additional files for the doc directory>d is filename of link>
# Links: <pair of space-separated paths; First is path symlink points at, second is filename of link>
# Files: <pair of space-separated paths; First is file to include, second is destination>
#  <more pairs, if there's more than one file to include. Notice the starting space>
Description: fake package to provide libpython3.10 for rocm
  fake package to provide libpython3.10 for rocm
EOF
equivs-build libpython-fake.equivs

sudo apt install ./libpython3.10-fake_3.10.12-1~22.04.3_all.deb