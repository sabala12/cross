FROM		ubuntu:16.04
MAINTAINER	sabala.eran@gmail.com

ENV 	DEBIAN_FRONTEND noninteractive
RUN 	dpkg-reconfigure locales && \
	locale-gen en_US.UTF-8 && \
	update-locale LANG=en_US.UTF-8
ENV	LANG en_US.UTF-8
ENV	LANGUAGE en_US:en
ENV	LC_ALL en_US.UTF-8

RUN	apt-get update && \
	apt-get install -y \
	software-properties-common \
	python-software-properties

ENV	BIN_VER		2.26
ENV	GCC_VER		7.xx
ENV	GLIBC_VER	xx
ENV	MPFR_VER	xx
ENV	GMP_VER		xx
ENV 	MPC_VER		xx
ENV	ISL_VER		xx
ENV	CLONG_VER	xx

ENV	CROSS_DIR		/opt/cross
ENV	CROSS_SOURCES_DIR	/opt/cross-sources
ENV	PATH			$PATH:$CROSS_DIR/bin
ENV	TARGET			x86_64-elf

RUN	mkdir $CROSS_SOURCES_DIR
RUN	mkdir $CROSS_DIR
WORKDIR $CROSS_SOURCES_DIR

RUN	wget http://ftpmirror.gnu.org/binutils/binutils-$BIN_VER.tar.gz && \
	wget http://ftpmirror.gnu.org/gcc/gcc-$GCC_VER/gcc-$GCC_VER.tar.gz && \
	wget http://ftpmirror.gnu.org/glibc/glibc-$GLIBC_VER.tar.x && \
	wget http://ftpmirror.gnu.org/mpfr/mpfr-$MPFR_VER.tar.xz && \
	wget http://ftpmirror.gnu.org/gmp/gmp-$GMP_VER.tar.xz && \
	wget http://ftpmirror.gnu.org/mpc/mpc-$MPC_VER.tar.gz && \
	wget ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-$ISL_VER.tar.bz2 && \
	wget ftp://gcc.gnu.org/pub/gcc/infrastructure/cloog-$CLONG_VER.tar.gz

RUN	for f in *.tar*; do tar xf $f; done		
RUN	cd gcc-$GCC_VER && \
	ln -s ../mpfr-$MPFR_VER mpfr
	ln -s ../gmp-$GMP_VER gmp && \
	ln -s ../mpc-$MPC_VER mpc && \
	ln -s ../isl-$ISL_VER isl && \
	ln -s ../cloog-$CLONG_VER cloog

RUN	mkdir build-binutils && \
	cd build-binutils && \
	../binutils-$BIN_VER/configure --prefix=$CROSS_DIR --target=$TARGET --disable-multilib && \
	make && \
	make install

RUN 	mkdir build-gcc && \
	cd build-gcc && \
	../gcc-$GCC_VER/configure --prefix=$CROSS_DIR --target=$TARGET --enable-languages=c,c++ --disable-multilib && \
	make all-gcc && \
	make install-gcc && \
