FILESEXTRAPATHS_append_class-native := ":${THISDIR}/files"

SRC_URI_append_class-native = " file://0001-add-evm-signature-on-file-deployment.patch"

DEPENDS_class-native += " openssl-native"