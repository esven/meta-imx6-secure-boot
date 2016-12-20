# This file is intended for devices that currently do not have FDT support
# enabled in U-Boot but still want to benefit from verified boot feature.
# It is based on the uboot-sign.bbclass from OE-Core Layer but creates a
# default Control-FDT file that is embedded into U-Boot during compilation after
# the Public Key has been appended.
#
# simple-control-dt:do_deploy
# virtual/kernel:do_assemble_fitimage
# u-boot:do_compile

CONTROL_DT_RECIPE ?= "simple-control-dt"

python () {
	uboot_pn = d.getVar('PREFERRED_PROVIDER_u-boot', True) or 'u-boot'
	kernel_pn = d.getVar('PREFERRED_PROVIDER_virtual/kernel', True)
	if d.getVar('UBOOT_SIGN_ENABLE', True) == '1' and d.getVar('PN', True) == uboot_pn:
		# Delete the tasks added by uboot-sign.bbclass as they will not succeed
		bb.build.deltask('do_deploy_dtb', d)
		bb.build.deltask('do_concat_dtb', d)
		
		# Depend on the assemble_fitimage task because it adds the public key to
		# the DTB in DEPLOY_DIR_IMAGE.
		d.appendVarFlag('do_compile', 'depends', ' %s:do_assemble_fitimage' % kernel_pn)
		deploydir = d.getVar('DEPLOY_DIR_IMAGE', True)
		dtbinary = d.getVar('UBOOT_DTB_BINARY', True)
		# Append EXT_DTB parameter to oemake, so that U-Boot can embed the DTB
		# during compilation.
		d.appendVar('EXTRA_OEMAKE', ' EXT_DTB=\"%s/%s\"' % ( deploydir, dtbinary ))

	if d.getVar('UBOOT_SIGN_ENABLE', True) == '1' and d.getVar('PN', True) == kernel_pn:
		# Retrieve the Control-DTB Recipe
		controlDt = d.getVar('CONTROL_DT_RECIPE', True)
		flags = d.getVarFlag('do_assemble_fitimage', 'depends', True)
		# do_assemble_fitimage now depends on CONTROL_DT_RECIPE:do_deploy instead
		# of u-boot:do_deploy as this would create a circular dependency.
		flags = flags.replace( ' %s:do_deploy' % uboot_pn, '%s:do_deploy' % controlDt)
		d.setVarFlag('do_assemble_fitimage', 'depends', flags)
		image = d.getVar('INITRAMFS_IMAGE', True)
		if image:
			flags = d.getVarFlag('do_assemble_fitimage_initramfs', 'depends', True)
			flags = flags.replace( ' %s:do_deploy' % uboot_pn, '%s:do_deploy' % controlDt)
			d.setVarFlag('do_assemble_fitimage_initramfs', 'depends', flags)
			d.appendVarFlag('do_assemble_fitimage_initramfs', 'depends', '%s:do_deploy' % controlDt)
}
