# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit subversion

ESVN_REPO_URI="https://forja.rediris.es/svn/cusl3-tucan/trunk/"
ESVN_PROJECT="tucan-svn"
ESVN_STORE_DIR="${D}/svn-src"

LICENSE="GPLv3"
SLOT="0"
KEYWORDS=""

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
