# ex:ts=4:sw=4:sts=4:et
# -*- tab-width: 4; c-basic-offset: 4; indent-tabs-mode: nil -*-
#
# Copyright (c) 2014, Intel Corporation.
# All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
# DESCRIPTION
# This implements the 'signed-rootfs' source plugin class for 'wic'
#
# AUTHORS
# Tom Zanussi <tom.zanussi (at] linux.intel.com>
# Joao Henrique Ferreira de Freitas <joaohf (at] gmail.com>
# Sven Ebenfeld <sven.ebenfeld (at] gmail.com>
#

import os

from wic import msger
from wic.pluginbase import SourcePlugin
from wic.utils.oe.misc import get_bitbake_var
from wic.utils.oe.misc import exec_cmd, exec_native_cmd

class SignedRootfsPlugin(SourcePlugin):
    """
    Populate partition content from a rootfs directory.
    """

    name = 'signed-rootfs'

    @staticmethod
    def __get_rootfs_dir(rootfs_dir):
        if os.path.isdir(rootfs_dir):
            return rootfs_dir

        image_rootfs_dir = get_bitbake_var("IMAGE_ROOTFS", rootfs_dir)
        if not os.path.isdir(image_rootfs_dir):
            msg = "No valid artifact IMAGE_ROOTFS from image named"
            msg += " %s has been found at %s, exiting.\n" % \
                (rootfs_dir, image_rootfs_dir)
            msger.error(msg)

        return image_rootfs_dir
    
    @staticmethod
    def __get_signing_key():
        image_signing_key = get_bitbake_var("IMA_EVM_PRIVKEY")
        if not image_signing_key or not os.path.isdir(image_signing_key):
            msg = "No valid artifact IMA_EVM_PRIVKEY"
            msg += " has been found at %s, exiting.\n" % \
                (image_signing_key)
            msger.error(msg)

        return image_signing_key
    

    @classmethod
    def do_prepare_partition(cls, part, source_params, cr, cr_workdir,
                             oe_builddir, bootimg_dir, kernel_dir,
                             krootfs_dir, native_sysroot):
        """
        Called to do the actual content population for a partition i.e. it
        'prepares' the partition to be incorporated into the image.
        In this case, prepare content for legacy bios boot partition.
        """
        if part.rootfs_dir is None:
            if not 'ROOTFS_DIR' in krootfs_dir:
                msg = "Couldn't find --rootfs-dir, exiting"
                msger.error(msg)
            rootfs_dir = krootfs_dir['ROOTFS_DIR']
        else:
            if part.rootfs_dir in krootfs_dir:
                rootfs_dir = krootfs_dir[part.rootfs_dir]
            elif part.rootfs_dir:
                rootfs_dir = part.rootfs_dir
            else:
                msg = "Couldn't find --rootfs-dir=%s connection"
                msg += " or it is not a valid path, exiting"
                msger.error(msg % part.rootfs_dir)

        real_rootfs_dir = cls.__get_rootfs_dir(rootfs_dir)

        part.rootfs_dir = real_rootfs_dir
        print ('Used the correct thing')

        cls.prepare_rootfs_ext4_signed(cr_workdir, oe_builddir, real_rootfs_dir, native_sysroot, part)

    @classmethod
    def prepare_rootfs_ext4_signed(cls, cr_workdir, oe_builddir, rootfs_dir,
                       native_sysroot, partition):
        print ('Started the correct thing')
        """
        Prepare content for a rootfs partition i.e. create a partition
        and fill it from a /rootfs dir.

        Currently handles ext2/3/4, btrfs and vfat.
        """
        p_prefix = os.environ.get("PSEUDO_PREFIX", "%s/usr" % native_sysroot)
        p_localstatedir = os.environ.get("PSEUDO_LOCALSTATEDIR",
                                         "%s/../pseudo" % rootfs_dir)
        p_passwd = os.environ.get("PSEUDO_PASSWD", rootfs_dir)
        p_nosymlinkexp = os.environ.get("PSEUDO_NOSYMLINKEXP", "1")
        pseudo = "export PSEUDO_PREFIX=%s;" % p_prefix
        pseudo += "export PSEUDO_LOCALSTATEDIR=%s;" % p_localstatedir
        pseudo += "export PSEUDO_PASSWD=%s;" % p_passwd
        pseudo += "export PSEUDO_NOSYMLINKEXP=%s;" % p_nosymlinkexp
        pseudo += "%s/usr/bin/pseudo " % native_sysroot

        rootfs = "%s/rootfs_%s.%s.%s" % (cr_workdir, partition.label,
                                         partition.lineno, partition.fstype)
        if os.path.isfile(rootfs):
            os.remove(rootfs)
        """
        Prepare content for an ext2/3/4 rootfs partition.
        """
        du_cmd = "du -ks %s" % rootfs_dir
        out = exec_cmd(du_cmd)
        actual_rootfs_size = int(out.split()[0])

        extra_blocks = partition.get_extra_block_count(actual_rootfs_size)
        if extra_blocks < partition.extra_space:
            extra_blocks = partition.extra_space

        rootfs_size = actual_rootfs_size + extra_blocks
        rootfs_size *= partition.overhead_factor

        msger.debug("Added %d extra blocks to %s to get to %d total blocks" % \
                    (extra_blocks, partition.mountpoint, rootfs_size))

        exec_cmd("truncate %s -s %d" % (rootfs, rootfs_size * 1024))

        extra_imagecmd = "-i 8192"
        """key_file = cls.__get_signing_key()"""
        key_file = "/home/esven/openembedded/krogoth/poky/meta-intel-iot-security/meta-integrity/scripts/keys/privkey_ima.pem"

        label_str = ""
        if partition.label:
            label_str = "-L %s" % partition.label

        mkfs_cmd = "mkfs.%s -F %s %s -k %s %s -d %s" % \
            (partition.fstype, extra_imagecmd, rootfs, key_file, label_str, rootfs_dir)
        print ("%s" % mkfs_cmd)
        exec_native_cmd(mkfs_cmd, native_sysroot, pseudo=pseudo)

        partition.source_file = rootfs

        # get the rootfs size in the right units for kickstart (kB)
        du_cmd = "du -Lbks %s" % rootfs
        out = exec_cmd(du_cmd)
        partition.size = out.split()[0]



