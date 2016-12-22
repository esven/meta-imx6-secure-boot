# Simple initramfs image. Mostly used for live images.
DESCRIPTION = "Small image capable of booting a device with IMA/EVM enabled."

PACKAGE_INSTALL = "initramfs-evm-init \
	busybox \
	base-passwd \
	${ROOTFS_BOOTSTRAP_INSTALL} \
	appraisal-ima-policy \
	"

# Do not pollute the initrd image with rootfs features
IMAGE_FEATURES = ""

export IMAGE_BASENAME = "initramfs-evm-init-image"
IMAGE_LINGUAS = ""

LICENSE = "MIT"

IMAGE_FSTYPES = "${INITRAMFS_FSTYPES}"
inherit core-image

IMAGE_ROOTFS_SIZE = "8192"
IMAGE_ROOTFS_EXTRA_SPACE = "0"

BAD_RECOMMENDATIONS += "busybox-syslog"
