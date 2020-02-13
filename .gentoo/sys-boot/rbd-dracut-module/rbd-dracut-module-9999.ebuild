# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Dracut module to boot from Rados Block Device (RBD - Ceph)"
HOMEPAGE="https://github.com/GITHUB_REPOSITORY"
LICENSE="GPL-3"

if [[ ${PV} = *9999* ]]; then
    inherit git-r3
    EGIT_REPO_URI="https://github.com/GITHUB_REPOSITORY"
    EGIT_BRANCH="GITHUB_REF"
else
    SRC_URI="https://github.com/GITHUB_REPOSITORY/archive/${PV}.tar.gz -> ${P}.tar.gz"
fi

KEYWORDS=""
IUSE="test"
SLOT="0"

RDEPEND="sys-apps/haveged
    sys-cluster/rbd-client-tools
    sys-kernel/dracut
    sys-process/procps"

src_install() {
    einstalldocs

    exeinto /usr/lib/dracut/modules.d/95rbd
    doexe usr/lib/dracut/modules.d/95rbd/*
}
