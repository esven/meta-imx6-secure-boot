
python __anonymous () {
	if d.getVar('UBOOT_SIGN_ENABLE', True):
		d.appendVar("DEPENDS", " cst-native")
		bb.build.addtask('do_sign_uboot_binaries', 'do_deploy do_install', 'do_compile', d)
}


#
# Emit the CSF File
#
# $1 ... .csf filename
# $2 ... SRK Table Binary
# $3 ... CSF Key File
# $4 ... Image Key File
# $5 ... Blocks Parameter
# $6 ... Image File
csf_emit_file() {
	cat << EOF >> ${1}
[Header]
Version = 4.1
Hash Algorithm = sha256
Engine = ANY
Engine Configuration = 0
Certificate Format = X509
Signature Format = CMS
[Install SRK]
File = "${2}"
Source index = 0
[Install CSFK]
File = "${3}"
[Authenticate CSF]
[Install Key]
Verification index = 0
Target Index = 2
File= "${4}"
[Authenticate Data]
Verification index = 2
Blocks = ${5} "${6}"
EOF
}

#
# Assemble csf binary
#
# $1 ... .csf filename
# $2 ...  signeable binary filename
# 
csf_assemble() {
	rm -f ${1}
	blocks="$(sed -n 's/HAB Blocks:[\t ]\+\([0-9a-f]\+\)[ ]\+\([0-9a-f]\+\)[ ]\+\([0-9a-f]\+\)/0x\1 0x\2 0x\3/p' ${2}.log)"
	csf_emit_file ${1} ${HAB_SIGN_SRKTABLE} \
	${HAB_SIGN_CSFKEY} \
	${HAB_SIGN_IMGKEY} \
	"${blocks}" ${2}

}

do_sign_uboot_binaries() {
	cd ${B}
	
	csf_assemble command_sequence_${UBOOT_BINARY}.csf ${UBOOT_BINARY}
	cst --o ${UBOOT_BINARY}.csf --i command_sequence_${UBOOT_BINARY}.csf
	cat ${UBOOT_BINARY} ${UBOOT_BINARY}.csf > ${UBOOT_BINARY}.tmp
	rm -f ${UBOOT_BINARY}
	mv ${UBOOT_BINARY}.tmp ${UBOOT_BINARY}
	if [ -n "${SPL_BINARY}" ]; then
		csf_assemble command_sequence_${SPL_BINARY}.csf ${SPL_BINARY}
		cst --o ${SPL_BINARY}.csf --i command_sequence_${SPL_BINARY}.csf
		cat ${SPL_BINARY} ${SPL_BINARY}.csf > ${SPL_BINARY}.tmp
		rm -rf ${SPL_BINARY}
		mv ${SPL_BINARY}.tmp ${SPL_BINARY}
	fi
}
