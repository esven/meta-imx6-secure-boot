require recipes-bsp/u-boot/u-boot.inc

DEPENDS += "dtc-native"

SRCREV = "3fd2cbfa03301a94dfef22da62de3c84c855fe47"
SRC_URI = "git://github.com/esven/u-boot-imx.git;branch=imx-wandboard-fitimage"

PV = "v2017.01+git${SRCPV}"

inherit uboot-embed-sign uboot-hab-signature
