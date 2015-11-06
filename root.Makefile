
# Process version information
#
# We want to append the first 8 digits of the HEAD SHA1 hash and also
# append a dirty mark if there's changes that aren't committed.
GIT_VER := $(shell cd toolchains ; git rev-parse --verify --short=8 HEAD)
ifneq ($(strip $(shell \
				cd toolchains ; \
				git update-index -q --refresh ; \
				git diff-index --name-only HEAD -- ;  )), )
	GIT_DIRTY := +
endif

# Release builds will have a release version # set via LARID_RELEASE in the passed
# environment if this is a release build. If not, then we'll make the version number
# just today's date.
ifdef LARID_RELEASE
	VERSION := $(LARID_RELEASE)-$(GIT_VER)$(GIT_DIRTY)
	VERSION_STR = Laird $(<F) release $(VERSION)
else
	VERSION :=  $(shell date +%Y%m%d)-$(GIT_VER)$(GIT_DIRTY)
	VERSION_STR = Laird $(<F) development build $(VERSION)
endif

##############
# Main targets
##############
all: wb-arm msd-x86

output:
	mkdir output

archive:
	mkdir archive

ct-ng: ct-ng.stamp

ct-ng.stamp:
	cd crosstool-ng && \
	./bootstrap && \
	./configure --enable-local && \
	$(MAKE) MAKELEVEL=0
	touch ct-ng.stamp

output/arm-laird-linux-gnueabi: output archive ct-ng.stamp
	mkdir -p working/$(@F)
	cp toolchains/$(@F).config_defconfig working/$(@F)/defconfig
	cd working/$(@F) && ../../crosstool-ng/ct-ng defconfig
	cd working/$(@F) && ../../crosstool-ng/ct-ng build

output/i586-laird-linux-gnu: output archive ct-ng.stamp
	mkdir -p working/$(@F)
	cp toolchains/$(@F).config_defconfig working/$(@F)/defconfig
	cd working/$(@F) && ../../crosstool-ng/ct-ng defconfig
	cd working/$(@F) && ../../crosstool-ng/ct-ng build

output/arm-larid-linux-gnueabi/laird_version.txt: output/arm-laird-linux-gnueabi
	repo manifest -r -o $</manifest-$(VERSION).xml
	cd $< && echo $(VERSION_STR) > laird_version.txt

arm-laird-linux-gnueabi_$(VERSION).tar.bz2: output/arm-laird-linux-gnueabi \
											output/arm-larid-linux-gnueabi/laird_version.txt
	cd output && tar cjf $@ $(<F)
	cp output/$@ .

output/i586-laird-linux-gnu/laird_version.txt: output/i586-laird-linux-gnu
	repo manifest -r -o $</manifest-$(VERSION).xml
	cd $< && echo $(VERSION_STR) > laird_version.txt

i586-laird-linux-gnu_$(VERSION).tar.bz2: output/i586-laird-linux-gnu \
										 output/i586-laird-linux-gnu/laird_version.txt
	cd output && tar cjf $@ $(<F)
	cp output/$@ .

output/arm-none-eabi: output archive ct-ng.stamp
	mkdir -p working/$(@F)
	cp toolchains/$(@F).config_defconfig working/$(@F)/defconfig
	cd working/$(@F) && ../../crosstool-ng/ct-ng defconfig
	cd working/$(@F) && ../../crosstool-ng/ct-ng build

output/arm-none-eabi/laird_version.txt: output/arm-none-eabi
	repo manifest -r -o $</manifest-$(VERSION).xml
	cd $< && echo $(VERSION_STR) > laird_version.txt

arm-none-eabi_$(VERSION).tar.bz2: output/arm-none-eabi \
								  output/arm-none-eabi/laird_version.txt
	cd output && tar cjf $@ $(<F)
	cp output/$@ .

samba: arm-none-eabi_$(VERSION).tar.bz2

wb-arm: arm-laird-linux-gnueabi_$(VERSION).tar.bz2

msd-x86: i586-laird-linux-gnu_$(VERSION).tar.bz2

dist-clean:
	-chmod -R a+w output 
	-rm -rf output working
	-cd crosstool-ng && git clean -xf
	-rm ct-ng.stamp

.PHONY: all dist-clean ct-ng wb-arm msd-x86 samba
