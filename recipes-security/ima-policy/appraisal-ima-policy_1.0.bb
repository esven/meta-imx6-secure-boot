DESCRIPTION = "Simple Control DTB for use with U-Boot for Devices without DTB \
               Support just used to support Public Key Attachment"
AUTHOR = "Sven Ebenfeld <sven.ebenfeld@gmail.com>"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${WORKDIR}/appraisal-policy.ima;beginline=1;endline=12;md5=1e1a19e657370adde7862a396c1b0752"

SRC_URI = "file://appraisal-policy.ima"
SRC_URI[md5sum] = "1"
SRC_URI[sha256sum] = "1"

do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${sysconfdir}/ima
    install -m 0644 ${WORKDIR}/appraisal-policy.ima ${D}${sysconfdir}/ima
    ln -sf ${sysconfdir}/ima/appraisal-policy.ima ${D}${sysconfdir}/ima/ima-policy
}