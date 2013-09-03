#!/bin/sh

# If getarg is not defined then source the dracut lib.
type getarg >/dev/null 2>&1 || . /lib/dracut-lib.sh

# If write_fs_tab is not defined then source the fs lib.
type write_fs_tab >/dev/null 2>&1 || . /lib/fs-lib.sh

# Ensure the PATH is sufficiently encompassing.
PATH=/usr/sbin:/usr/bin:/sbin:/bin

# Source the parse-rbdroot.sh script - this will split the root= 
# argument into rbd_pool, rbd_name, rbd_fstype and rbd_rootflags.
. $moddir/parse-rbdroot.sh

# Attempt to map the rbd device.
rbd map $rbd_name --pool $rbd_pool || die "Unable to mount rbd device \"$rbd_name\" from pool \"$rbd_pool\""
wait_for_dev /dev/rbd/$rbd_pool/$rbd_name

# Create a link for /dev/root
ln -s /dev/rbd/$rbd_pool/$rbd_name /dev/root

# Create an fstab entry for our root filesystem.
write_fs_tab /dev/root "$rbd_fstype" "$rbd_rootflags"
wait_for_dev /dev/root

# We should be done!
exit 0
