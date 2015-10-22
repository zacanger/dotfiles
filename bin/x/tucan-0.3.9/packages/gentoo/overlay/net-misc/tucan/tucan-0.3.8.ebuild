# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="Software designed for automatic management of downloads and uploads at hosting sites like rapidshare or megaupload"
HOMEPAGE="http://tucaneando.com/"
SRC_URI="http://forja.rediris.es/frs/download.php/1400/${P}.tar.gz"

LICENSE="GPLv3"
SLOT="0"
KEYWORDS="~x86 ~amd64"

IUSE=""
DEPEND="dev-lang/python
		dev-python/pygtk
		dev-python/imaging
		app-text/tesseract[linguas_en]
		gnome-base/librsvg"

src_compile() {
	sed -i \
		-e '/^DESTDIR/d' \
		Makefile || die "sed failed"
}

src_install() {
	emake DESTDIR="${D}"/usr install || die "emake install failed"
	dodoc CHANGELOG README || die
	newicon media/tucan.svg "${PN}.svg"
}
