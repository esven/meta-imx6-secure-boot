FILESEXTRAPATHS_append_class-native := ":${THISDIR}/files"

SRC_URI_append_class-native = " file://0001-add-evm-signature-on-file-deployment.patch"

PACKAGECONFIG_append_class-native = "openssl"
PACKAGECONFIG[openssl] = "--with-openssl=yes,,openssl"