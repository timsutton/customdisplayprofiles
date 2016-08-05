PKGVERSION=1.0.0
PKGNAME=customdisplayprofiles
PKGID=com.github.timsutton.customdisplayprofiles
BUILDPATH=build
INSTALLPATH=/usr/local/bin
MUNKI_REPO_SUBDIR=utilities

all: clean pkg
clean:
	rm -f ${BUILDPATH}/${PKGNAME}-${PKGVERSION}.pkg
	rm -rf pkgroot
pkg: 
	mkdir -p ${BUILDPATH}
	mkdir -p pkgroot/${INSTALLPATH}
	cp customdisplayprofiles pkgroot/${INSTALLPATH}
	pkgbuild --root pkgroot --identifier ${PKGID} --version ${PKGVERSION} ${BUILDPATH}/${PKGNAME}-${PKGVERSION}.pkg
munki:
	munkiimport --unattended-install --catalog=testing -n --subdirectory ${MUNKI_REPO_SUBDIR} --developer='Tim Sutton' ${BUILDPATH}/${PKGNAME}-${PKGVERSION}.pkg && makecatalogs


