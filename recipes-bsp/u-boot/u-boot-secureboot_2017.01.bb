require recipes-bsp/u-boot/u-boot.inc

DEPENDS += "dtc-native"

SRCREV = "70badf8e5b99083544b28b8babdc68bd61cbc192"
SRC_URI = "git://github.com/esven/u-boot-imx.git;branch=imx-wandboard-fitimage"

PV = "v2017.01+git${SRCPV}"

inherit uboot-embed-sign uboot-hab-signature
