# $Id: PKGBUILD 46026 2011-05-02 07:40:35Z andrea $
# Maintainer:
# Contributor: Jeff Mickey <j@codemac.net>

pkgname=wtf
pkgver=20111222
pkgrel=1
pkgdesc="Ancronym dictionary"
arch=('any')
url="http://www.mu.org/~mux/wtf/"
license=('BSD')
source=("http://www.mu.org/~mux/${pkgname}/${pkgname}-${pkgver}.tar.gz"
        'LICENSE')
md5sums=('25944e275cc858e30cacea341509d19b'
         'abac213cf24e9d5cab4e8115441eb717')

package() {
  cd "${srcdir}/${pkgname}-${pkgver}"

  install -D -m644 $pkgname.6 "${pkgdir}/usr/share/man/man6/$pkgname.6"
  install -D -m755 $pkgname "${pkgdir}/usr/bin/$pkgname"
  install -d "${pkgdir}/usr/share/misc/"
  install -m644 acronyms acronyms.comp acronyms.computing "${pkgdir}/usr/share/misc/"
  install -Dm644 "${srcdir}/LICENSE" \
    "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}
