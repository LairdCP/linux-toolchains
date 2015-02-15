
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

arm-laird-linux-gnueabi.tar.bz2: output/arm-laird-linux-gnueabi
	cd output && tar cjf $@ $(<F)
	cp output/$@ .

i586-laird-linux-gnu.tar.bz2: output/i586-laird-linux-gnu
	cd output && tar cjf $@ $(<F)
	cp output/$@ .

wb-arm: arm-laird-linux-gnueabi.tar.bz2

msd-x86: i586-laird-linux-gnu.tar.bz2

dist-clean:
	-chmod -R a+w output 
	-rm -rf output working
	-cd crosstool-ng && git clean -xf
	-rm ct-ng.stamp

.PHONY: all dist-clean ct-ng wb-arm msd-x86