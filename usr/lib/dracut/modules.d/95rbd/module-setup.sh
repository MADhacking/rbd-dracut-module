#! /bin/bash

check()
{
    # If we don't have rbd installed then we're done already!
    type -P rbd >/dev/null || return 1

    return 0
}

depends()
{
    # We depend on network modules being loaded
    echo network rootfs-block
}

installkernel()
{
    instmods rbd
}

install()
{
    inst rbd
    inst_hook cmdline 90 "$moddir/parse-rbdroot.sh"
    inst_script "$moddir/rbdroot.sh" "/sbin/rbdroot"
    dracut_need_initqueue
}
