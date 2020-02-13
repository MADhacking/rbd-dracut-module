#!/bin/sh

# Sadly there's no easy way to split ':' separated lines into variables
root_to_vars()
{
    v=${1}:
    set --
    while [ -n "$v" ]; do
        set -- "$@" "${v%%:*}"
        v=${v#*:}
    done

    unset rbd_pool rbd_name rbd_fstype rbd_rootflags
    export rbd_pool=$2
    export rbd_name=$3
    export rbd_fstype=$4
    export rbd_rootflags=$5
}

# If getarg is not defined then source the dracut lib.
# shellcheck disable=SC1091
type getarg >/dev/null 2>&1 || . /lib/dracut-lib.sh

# If it's not rbd we don't continue.
root=$(getarg root=)
[ "${root%%:*}" = "rbd" ] || return

# Parse root= argument.
root_to_vars "$root"

# If write_fs_tab is not defined then source the fs lib.
# shellcheck disable=SC1091
type write_fs_tab >/dev/null 2>&1 || . /lib/fs-lib.sh

# Ensure the PATH is sufficiently encompassing.
PATH=/usr/sbin:/usr/bin:/sbin:/bin

# Ensure we have sufficient entropy available.
echo "Seeding /dev/random with haveged"
haveged

# Attempt to map the rbd device.
rbd map "$rbd_name" --pool "$rbd_pool" || die "Unable to mount rbd device \"$rbd_name\" from pool \"$rbd_pool\""
wait_for_dev "/dev/rbd/$rbd_pool/$rbd_name"

# Create a link for /dev/root
ln -s "/dev/rbd/$rbd_pool/$rbd_name" /dev/root

# Create an fstab entry for our root filesystem.
write_fs_tab /dev/root "$rbd_fstype" "$rbd_rootflags"
wait_for_dev /dev/root

# Kill haveged, if the user wants it they can start it themselves.
pkill -x haveged

# We should be done!
exit 0
