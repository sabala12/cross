FROM		ubuntu:14.04
MAINTAINER	sabala.eran@gmail.com

# General enviorment variables
ENV 	DEBIAN_FRONTEND		noninteractive
RUN 	dpkg-reconfigure locales && \
	locale-gen en_US.UTF-8 && \
	update-locale LANG=en_US.UTF-8

ENV	LANG			en_US.UTF-8
ENV	LANGUAGE		en_US:en
ENV	LC_ALL			en_US.UTF-8

# Download some dependencies
RUN	apt-get update && \
	apt-get install -y \
	software-properties-common \
	python-software-properties \
	wget make gcc g++

# Define versions
ENV	BIN_VER		2.26
ENV	GCC_VER		7.2.0
ENV	GLIBC_VER	2.26
ENV	MPFR_VER	3.1.6
ENV	GMP_VER		6.1.2
ENV 	MPC_VER		1.0.3
ENV	ISL_VER		0.12.2
ENV	CLONG_VER	0.18.1

# Specific build information 
ENV	CROSS_DIR		/opt/cross
ENV	CROSS_SOURCES_DIR	/opt/cross-sources
ENV	PATH			$PATH:$CROSS_DIR/bin
ENV	TARGET			x86_64-elf

RUN	mkdir $CROSS_SOURCES_DIR
RUN	mkdir $CROSS_DIR
WORKDIR $CROSS_SOURCES_DIR

# Download dependencies
RUN	wget http://ftp.sotirov-bg.net/pub/mirrors/gnu/binutils/binutils-$BIN_VER.tar.gz && \
	wget http://ftp.sotirov-bg.net/pub/mirrors/gnu/gcc/gcc-$GCC_VER/gcc-$GCC_VER.tar.gz && \
	wget http://ftp.sotirov-bg.net/pub/mirrors/gnu/glibc/glibc-$GLIBC_VER.tar.gz && \
	wget http://ftp.sotirov-bg.net/pub/mirrors/gnu/mpfr/mpfr-$MPFR_VER.tar.gz && \
	wget http://ftp.sotirov-bg.net/pub/mirrors/gnu/gmp/gmp-$GMP_VER.tar.xz && \
	wget http://ftp.sotirov-bg.net/pub/mirrors/gnu/mpc/mpc-$MPC_VER.tar.gz

# Extract dependencies
RUN	for f in *.tar*; do tar xf $f; done		
RUN	cd gcc-$GCC_VER && \
	ln -s ../mpfr-$MPFR_VER mpfr && \
	ln -s ../gmp-$GMP_VER gmp && \
	ln -s ../mpc-$MPC_VER mpc

# Build Binutils
RUN	mkdir build-binutils && \
	cd build-binutils && \
	../binutils-$BIN_VER/configure --prefix=$CROSS_DIR --target=$TARGET --with-sysroot --disable-nls --disable-werror && \
	make 
 
# Build GCC
RUN 	mkdir build-gcc && \
	cd build-gcc && \
	../gcc-$GCC_VER/configure --prefix=$CROSS_DIR --target=$TARGET --disable-nls --enable-languages=c,c++ --without-headers && \
	make all-gcc

WORKDIR /opt
ADD	entry.sh	/opt
CMD	["/bin/bash"]




#	wget ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-$ISL_VER.tar.bz2 && \
#	wget ftp://gcc.gnu.org/pub/gcc/infrastructure/cloog-$CLONG_VER.tar.gz
#	ln -s ../isl-$ISL_VER isl && \
#	ln -s ../cloog-$CLONG_VER cloog
