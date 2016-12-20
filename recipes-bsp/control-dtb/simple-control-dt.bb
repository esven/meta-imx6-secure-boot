DESCRIPTION = "Simple Control DTB for use with U-Boot for Devices without DTB \
               Support just used to support Public Key Attachment"
AUTHOR = "Sven Ebenfeld <sven.ebenfeld@gmail.com>"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${WORKDIR}/simple-control.dts;beginline=1;endline=10;md5=408a8f171048b0a2bf52666927359fdd"
SRC_URI = "file://simple-control.dts"
SRC_URI[md5sum] = "1"
SRC_URI[sha256sum] = "1"

do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_install[noexec] = "1"

DEPENDS = "dtc-native"

inherit nopackages deploy uboot-sign

do_compile() {
    dtc ${UBOOT_MKIMAGE_DTCOPTS} -o ${B}/simple-control.dtb ${WORKDIR}/simple-control.dts
}

do_deploy() {
	mkdir -p ${DEPLOYDIR}
	cd ${DEPLOYDIR}

	if [ -f ${DEPLOYDIR}/simple-control.dtb ]; then
		rm ${DEPLOYDIR}/simple-control.dtb
	fi
	install -m 0644 ${B}/simple-control.dtb ${DEPLOYDIR}/${UBOOT_DTB_IMAGE}
	rm -f ${UBOOT_DTB_BINARY} ${UBOOT_DTB_SYMLINK}
	ln -sf ${UBOOT_DTB_IMAGE} ${UBOOT_DTB_SYMLINK}
	ln -sf ${UBOOT_DTB_IMAGE} ${UBOOT_DTB_BINARY}
}

addtask deploy before do_build after do_compile