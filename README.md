## Toolchains: ##

The following Laird toolchains are produced by this build system:

* arm-laird-linux-gnu - Main WB/MSD arm toolchain
* i586-laird-linux-gnu - x86-32 bit targeted MSD toolchain
* arm-none-eabi - Toolchain used to construct SAM-BA applets

## Setup: ##

This project uses Repo because it is a composite project.

If you're getting this from our distribution site, GitHub, you can use a manifest
created specially for this purpose:

    repo init -u https://github.com/LairdCP/linux-toolchains.git -m github.xml
    repo sync

For internal Laird use, there is a defeault.xml in this repository that is used to
actually get this and our crosstool-ng repositories, both of which are needed to
create the build environment:

    repo init -u git@git.devops.lairdtech.com:CP_linux/toolchains.git
    repo sync

## Building: ##

To just build all the toolchains:

    make

To just build the WB/MSD arm toolchain:

    make wb-arm

### Make targets ###

These are the top-level make targets and what they produce.

* wb-arm: arm-laird-linux-gnu
* msd-x86: i586-laird-linux-gnu
* samba: arm-none-eabi
* all: builds wb-arm and msd-x86.  samba toolchain is not normally needed.

## Experimenting: ##

To try different toolchain configurations:

    cd working/<toolchain_name>
    ../../crosstool-ng/ct-ng menuconfig
    ../../crosstool-ng/ct-ng build

## Version numbers: ##

As is similar with other Linux projects, the build versions the output. This is controlled
in the Makefile. Each built toolchain gets a file, `laird_version.txt` in the base
directory with a version string, and the final tarballs get the version number in the
file name.

Development builds get a datestamp in the form YYYYMMDD followed by an eight-digit Git
SHA-1 hash. This is suffixed by an indicator (`+`) if there were non-committed changes in
the repository when built.

A release build version number can be created by passing a value via the environment
variable `LAIRD_RELEASE`. This value is taken verbatim and is also suffixed by the same
Git commit hash and the dirty flag.

Release version numbers should be of the form:

    a.b.c.d

* a - Major release version number, loosely tied to the Linux project version number
* b - Minor release version number, tied to the Linux projects minor number
* c - Branch version
* d - Build number - increments on each release candidate build on Jenkins.

a.b will be set when we do the toolchain build to match the Linux project that it connects
with, but note that we will not necessarily reissue the toolchain when we increment WB
major.minor numbers, this number is indicative of the first Linux build that requires this
toolchain.

So, as of the time of this writing, the base release version number will be:

    3.5.2.d

A full release version number would be initiated by making like this:

    make LAIRD_RELEASE=3.5.2.0 wb-arm

Which would result in a full version: `3.5.2.0-6dd41768`

A non-release build would generate a version number `20151106-6dd41768`

A + will be added as a dirty flag on the end of that if there are non-committed changes in
the workspace.

## 32-bit/64-bit ##

The bitness of the target is defined by the toolchain configuration. Our ARM toolchains are
all targeted to 32-bit ARM targets. Our x86 msd toolchain is targeted to a 32-bit x86 since
most embedded x86 platforms are expected to be 32 bit.

The host the cross-compiler runs upon is dependent on the type of host the toolchain is
built on. Right now Laird uses 64-bit build slaves, so the toolchains will run on 64-bit
hosts only.
