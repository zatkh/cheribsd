#	@(#)Makefile	8.1 (Berkeley) 6/4/93
# $FreeBSD$

.include <src.opts.mk>

# The SUBDIR_BOOTSTRAP list is a small set of libraries which are used by many
# of the other libraries.  These are built first with a .WAIT between them
# and the main list to avoid needing a SUBDIR_DEPEND line on every library
# naming just these few items.

SUBDIR_BOOTSTRAP= \
	csu \
	.WAIT \
	libnetbsd \
	libc \
	libc_nonshared \
	libcompiler_rt \
	${_libc_cheri} \
	${_libcheri} \
	${_libclang_rt} \
	libgcc_eh \
	libgcc_s \
	${_libcplusplus} \
	${_libcxxrt} \
	libelf \
	libssp \
	libssp_nonshared \
	msun

# The main list; please keep these sorted alphabetically.

SUBDIR=	${SUBDIR_BOOTSTRAP} \
	.WAIT \
	geom \
	libalias \
	libarchive \
	libauditd \
	libbegemot \
	libblocksruntime \
	libbsdstat \
	libbsm \
	libbz2 \
	libc_nosyscalls \
	libcalendar \
	libcam \
	libcapsicum \
	libcasper \
	libcompat \
	libcrypt \
	libdevctl \
	libdevinfo \
	libdevstat \
	libdl \
	libdwarf \
	libedit \
	libelftc \
	libevent1 \
	libexecinfo \
	libexpat \
	libfetch \
	libfigpar \
	libgeom \
	libifconfig \
	libipsec \
	libjail \
	libjpeg \
	libkiconv \
	libkvm \
	liblua \
	liblzma \
	libmemstat \
	${_libstatcounters} \
	libmd \
	libmt \
	lib80211 \
	libnv \
	libopenbsd \
	libopie \
	libpam \
	libpathconv \
	libpcap \
	libpjdlog \
	libpng \
	libproc \
	libprocstat \
	libregex \
	librpcsvc \
	librss \
	librt \
	librtld_db \
	libsbuf \
	libsmb \
	libsqlite3 \
	libstdbuf \
	libstdthreads \
	libsysdecode \
	libtacplus \
	libucl \
	libufs \
	libugidfw \
	libulog \
	libutil \
	${_libvgl} \
	libwrap \
	libxo \
	liby \
	libz \
	libzstd \
	ncurses

.if !${MACHINE_ABI:Mpurecap}
# Needs changes to be useful for purecap and not used by anything (yet)
SUBDIR+=	libthread_db
.endif

# Inter-library dependencies.  When the makefile for a library contains LDADD
# libraries, those libraries should be listed as build order dependencies here.

SUBDIR_DEPEND_geom=	libufs
SUBDIR_DEPEND_libarchive= libz libbz2 libexpat liblzma libmd libzstd
SUBDIR_DEPEND_libauditdm= libbsm
SUBDIR_DEPEND_libbsnmp= ${_libnetgraph}
SUBDIR_DEPEND_libc++:= libcxxrt
# libssp_nonshared doesn't need to be linked into libc on every arch, but it is
# small enough to build that this bit of serialization is likely insignificant.
SUBDIR_DEPEND_libc= libcompiler_rt libssp_nonshared
SUBDIR_DEPEND_libcam= libsbuf
SUBDIR_DEPEND_libcasper= libnv
SUBDIR_DEPEND_libdevstat= libkvm
SUBDIR_DEPEND_libdpv= libfigpar ncurses libutil
SUBDIR_DEPEND_libedit= ncurses
SUBDIR_DEPEND_libgeom= libexpat libsbuf
SUBDIR_DEPEND_librpcsec_gss= libgssapi
SUBDIR_DEPEND_libmagic= libz
SUBDIR_DEPEND_libmemstat= libkvm
SUBDIR_DEPEND_libopie= libmd
SUBDIR_DEPEND_libpam= libcrypt libopie ${_libradius} librpcsvc libtacplus libutil ${_libypclnt} ${_libcom_err} 
SUBDIR_DEPEND_libpjdlog= libutil
SUBDIR_DEPEND_libprocstat= libkvm libutil
SUBDIR_DEPEND_libradius= libmd
SUBDIR_DEPEND_libsmb= libkiconv
SUBDIR_DEPEND_libtacplus= libmd
SUBDIR_DEPEND_libulog= libmd
SUBDIR_DEPEND_libunbound= ${_libldns}
SUBDIR_DEPEND_liblzma= ${_libthr}
.if ${MK_OFED} != "no"
SUBDIR_DEPEND_libpcap= ofed
.endif

# NB: keep these sorted by MK_* knobs

SUBDIR.${MK_ATM}+=	libngatm
SUBDIR.${MK_BEARSSL}+=	libbearssl libsecureboot
SUBDIR.${MK_BLACKLIST}+=libblacklist
SUBDIR.${MK_BLUETOOTH}+=libbluetooth libsdp
SUBDIR.${MK_BSNMP}+=	libbsnmp

SUBDIR.${MK_LIBCHERI}+=	libhelloworld
SUBDIR.${MK_CHERI}+=	libsyscalls

.if ${MK_LIBCHERI} == "yes" && ${MACHINE_ARCH} != "mips"
_libc_cheri=	libc_cheri
_libcheri=	libcheri
.endif

.if ${MACHINE_CPUARCH} == "mips" || ${MACHINE_CPUARCH} == "riscv"
SUBDIR+= libsimple_printf
.endif

.if !defined(COMPAT_32BIT) && !defined(COMPAT_64BIT) && !defined(COMPAT_SOFTFP) && !defined(COMPAT_CHERI)
SUBDIR.${MK_CLANG}+=	clang
.endif

SUBDIR.${MK_CUSE}+= 	libcuse
SUBDIR.${MK_CXX}+=	libdevdctl
SUBDIR.${MK_TOOLCHAIN}+=libpe
SUBDIR.${MK_DIALOG}+=	libdpv
SUBDIR.${MK_FILE}+=	libmagic
SUBDIR.${MK_GPIO}+=	libgpio
SUBDIR.${MK_GSSAPI}+=	libgssapi librpcsec_gss
SUBDIR.${MK_ICONV}+=	libiconv_modules
SUBDIR.${MK_KERBEROS_SUPPORT}+=	libcom_err
SUBDIR.${MK_LDNS}+=	libldns
SUBDIR.${MK_STATS}+=	libstats

# The libraries under libclang_rt can only be built by clang, and only make
# sense to build when clang is enabled at all.  Furthermore, they can only be
# built for certain architectures.
# XXXAR: This is not actually true, it makes sense to build them even if we
# aren't building a native clang since we might be cross-compiling with clang
.if ${COMPILER_TYPE} == "clang"
.if (${MACHINE_CPUARCH} == "aarch64" || ${MACHINE_CPUARCH} == "amd64" || \
    ${MACHINE_CPUARCH} == "arm" || ${MACHINE_CPUARCH} == "i386" || \
    ${MACHINE_CPUARCH} == "powerpc" || \
    ${MACHINE_ARCH:Mmips64*}) && \
    !${MACHINE_ABI:Mpurecap}
_libclang_rt=	libclang_rt
.elif !${MACHINE_ABI:Mpurecap} && ${MACHINE_ARCH} != "mips" && \
    ! ${MACHINE_ARCH:Mriscv*}
.error "NOT BUILDING libclang_rt for ${MACHINE_ARCH}"
.endif
.endif # ${COMPILER_TYPE} == "clang"

.if ${MK_LIBCPLUSPLUS} != "no"
_libcxxrt=	libcxxrt
_libcplusplus=	libc++
_libcplusplus+=	libc++experimental
.endif

SUBDIR.${MK_EFI}+=	libefivar
SUBDIR.${MK_GOOGLETEST}+=	googletest
SUBDIR.${MK_LIBTHR}+=	libthr
SUBDIR.${MK_NETGRAPH}+=	libnetgraph
SUBDIR.${MK_NIS}+=	libypclnt

.if ${MACHINE_CPUARCH} == "i386" || ${MACHINE_CPUARCH} == "amd64"
_libvgl=	libvgl
.endif

.if ${MACHINE_CPUARCH} == "aarch64"
SUBDIR.${MK_PMC}+=	libopencsd
.endif

.if ${MACHINE_CPUARCH} == "amd64"
SUBDIR.${MK_PMC}+=	libipt
SUBDIR.${MK_BHYVE}+=	libvmmapi
.endif

.if ${MACHINE_ARCH:Mmips64*}
_libstatcounters=	libstatcounters
.endif

.if ${MACHINE_ARCH} != "powerpc"
SUBDIR.${MK_OPENMP}+=	libomp
.endif
SUBDIR.${MK_OPENSSL}+=	libmp
SUBDIR.${MK_PMC}+=	libpmc libpmcstat
SUBDIR.${MK_RADIUS_SUPPORT}+=	libradius
SUBDIR.${MK_SENDMAIL}+=	libmilter libsm libsmdb libsmutil
SUBDIR.${MK_TELNET}+=	libtelnet
SUBDIR.${MK_TESTS_SUPPORT}+=	atf
SUBDIR.${MK_TESTS_SUPPORT}.${MK_CXX}+=	kyua
SUBDIR.${MK_TESTS_SUPPORT}.${MK_CXX}+=	liblutok
SUBDIR.${MK_TESTS}+=	tests
SUBDIR.${MK_UNBOUND}+=	libunbound
SUBDIR.${MK_USB}+=	libusbhid libusb
SUBDIR.${MK_OFED}+=	ofed
SUBDIR.${MK_VERIEXEC}+=	libveriexec
SUBDIR.${MK_ZFS}+=	libbe

.if !make(install)
SUBDIR_PARALLEL=
.endif

.if ${MK_CHERI} != "no"
# libc++experimental currently causes crashes
SUBDIR:=	${SUBDIR:Nlibc++experimental}
.endif

.if ${MACHINE_ABI:Mpurecap}
SUBDIR+=	libmalloc_simple
.endif
.if ${MK_LIBCHERI} == "yes"
SUBDIR.${MK_LIBCHERI}+=	libcheri_syscalls
SUBDIR.${MK_LIBCHERI}+=	libcheri_support
.endif

.include <bsd.subdir.mk>
