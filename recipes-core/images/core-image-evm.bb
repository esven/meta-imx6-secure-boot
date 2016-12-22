SUMMARY = "A small image just capable of allowing a device to do a verified boot."

IMAGE_INSTALL = "packagegroup-core-boot \
	${ROOTFS_PKGMANAGE_BOOTSTRAP} \
	${CORE_IMAGE_EXTRA_INSTALL} \
	"

IMAGE_LINGUAS = " "

LICENSE = "MIT"

inherit core-image

IMAGE_ROOTFS_SIZE ?= "8192"
IMAGE_ROOTFS_EXTRA_SPACE_append = "${@bb.utils.contains("DISTRO_FEATURES", "systemd", " + 4096", "" ,d)}"

copy_initramfs_fitimage() {
	cd ${IMAGE_ROOTFS}/boot
	
	rm ${IMAGE_ROOTFS}/boot/*
	RAMFS_FILENAME=$(readlink ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${INITRAMFS_IMAGE}-${MACHINE}.bin)
	cp ${DEPLOY_DIR_IMAGE}/${RAMFS_FILENAME} .
	ln -sf /boot/${RAMFS_FILENAME} ${KERNEL_IMAGETYPE}-${INITRAMFS_IMAGE}-${MACHINE}.bin
	ln -sf /boot/${RAMFS_FILENAME} ${KERNEL_IMAGETYPE}-initramfs.bin
}

ROOTFS_POSTPROCESS_COMMAND += " copy_initramfs_fitimage ; "

do_rootfs[depends] += " ${INITRAMFS_IMAGE}:do_image_complete"