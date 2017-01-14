DESCRIPTION = "Code Signing Tool for NXP's High Assurance Boot with i.MX processors."
AUTHOR = "NXP"
HOMEPAGE = "http://www.nxp.com"
LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://Release_Notes.txt;md5=ec86609b539c71fe8c987febd93ee14e"

SRC_URI = "https://cache.nxp.com/secured/NMG/MAD/cst-2.3.2.tar.gz?__gda__=1484440346_4db63f289d2506642da5d07dd3691c3f&fileExt=.gz;downloadfilename=hab-cst-2.3.2.tar.gz"
SRC_URI[md5sum] = "a81766cab2e184ab12e459c0476f6639"
SRC_URI[sha256sum] = "064bfe407ab8616d8caa2fa15c0b87b4a683535e08f95af7179ffaa7c2b74e32"

inherit native

S = "${WORKDIR}/cst-${PV}"

do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
  mkdir -p ${D}${bindir}
  install -m 0755 ${S}${SRCDIR}/cst ${D}${bindir}
  install -m 0755 ${S}${SRCDIR}/srktool ${D}${bindir}
  install -m 0755 ${S}${SRCDIR}/x5092wtls ${D}${bindir}
}

COMPATIBLE_HOST = "(i.86|x86_64).*-linux"
SRCDIR_x86-64 = "/linux64"
SRCDIR_x86 = "/linux32"
