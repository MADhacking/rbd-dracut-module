#! /bin/sh

# Preferred format:
#       root=rbd:pool:name:monitors[:fstype[:rootflags]]

# Sadly there's no easy way to split ':' separated lines into variables
root_to_vars()
{
    local v=${1}:
    set --
    while [ -n "$v" ]; do
        set -- "$@" "${v%%:*}"
        v=${v#*:}
    done

    unset rbd_pool rbd_name rbd_fstype rbd_rootflags
    rbd_pool=$2; rbd_name=$3; rbd_fstype=$4; rbd_rootflags=$5;
}

# This script is sourced, so root should be set. But let's be paranoid
[ -z "$root" ] && root=$(getarg root=)
[ -z "$netroot" ] && netroot=$(getarg netroot=)

# Root takes precedence over netroot
if [ "${root%%:*}" = "rbd" ] ; then
	
    # Don't continue if root is ok
    [ -n "$rootok" ] && return

    if [ -n "$netroot" ] ; then
        warn "root takes precedence over netroot. Ignoring netroot"
    fi
    netroot=$root
    unset root
fi

# If it's not rbd we don't continue
[ "${netroot%%:*}" != "rbd" ] && return

# Check required arguments
root_to_vars $netroot
[ -z "$rbd_pool" ] && die "Argument pool for rbd root is missing"
[ -z "$rbd_name" ] && die "Argument name for rbd root is missing"

# Done, all good!
rootok=1

# Shut up init error check
if [ -z "$root" ]; then
    root=block:/dev/root
    wait_for_dev /dev/root
fi
