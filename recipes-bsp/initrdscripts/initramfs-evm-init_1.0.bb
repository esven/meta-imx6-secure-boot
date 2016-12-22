SUMMARY = "Extremely basic live image init script for EVM/IMA initialization"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"
SRC_URI = "file://init-evm.sh"

S = "${WORKDIR}"

do_install() {
        install -m 0755 ${WORKDIR}/init-evm.sh ${D}/init
}

inherit allarch

FILES_${PN} += " /init "
