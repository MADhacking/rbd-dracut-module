#! /bin/sh

# Required format:
#       root=rbd:pool:name:fstype:rootflags

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

# This script is sourced, so root should be set. But let's be paranoid
[ -z "$root" ] && root=$(getarg root=)
[ -z "$netroot" ] && netroot=$(getarg netroot=)

# Root takes precedence over netroot
if [ "${root%%:*}" = "rbd" ] ; then
	
    # Don't continue if root is ok
    if [ -n "$rootok" ]; then
    	warn "root is already OK, we won't try to mount an rbd volume"
    	exit
    fi

    if [ -n "$netroot" ] ; then
        warn "root takes precedence over netroot. Ignoring netroot"
    fi
    netroot=$root
    unset root
fi

# If it's not rbd we don't continue
if [ "${netroot%%:*}" != "rbd" ]; then
	warn "We do not appear to have an rbd root specified as a kernel parameter"
	exit
fi

# Check required arguments
root_to_vars "$netroot"
[ -z "$rbd_pool" ] && die "Argument pool for rbd root is missing"
[ -z "$rbd_name" ] && die "Argument name for rbd root is missing"

# Done, all good!
rootok=1

# Shut up init error check
if [ -z "$root" ]; then
    root=block:/dev/root
    wait_for_dev /dev/root
fi
