#!/bin/bash
ROOT_DIR=$(dirname $(readlink -f $0))

# Python version: Change here if necessary
PYTHON_VERSION="3.8.5"

# ================================================== #

# Python archive
PYTHON_ARCHIVE="Python-$PYTHON_VERSION.tar.xz"
# Archive URL
PYTHON_ARCHIVE_URL="http://www.python.org/ftp/python/$PYTHON_VERSION/$PYTHON_ARCHIVE"
# Source directory (Directory in which the sources will be extracted)
SOURCE_DIRECTORY="Python-$PYTHON_VERSION"

# ================================================== #
# Preparing compile environment
# ================================================== #
TARGET_HOST="arm-linux-gnueabihf"
BUILD_HOST="x86_64-linux-gnu"

WORKING_DIRECTORY="$ROOT_DIR/build/$TARGET_HOST"
mkdir -p $WORKING_DIRECTORY

# .
# ├── python-3.8.5   Package directory
# │   ├── DEBIAN
# │   └── usr        Install directory
# └── README.md
#
PACKAGE_NAME="python-$PYTHON_VERSION"
PACKAGE_DIRECTORY="$ROOT_DIR/$PACKAGE_NAME"
INSTALL_DIRECTORY="$PACKAGE_DIRECTORY/usr"
mkdir -p $INSTALL_DIRECTORY
PREFIX=$(readlink --no-newline --canonicalize "$INSTALL_DIRECTORY")

ROOT_FILESYSTEM="/usr/arm-linux-gnueabi/"
export RFS="$ROOT_FILESYSTEM"
# ================================================== #

RED="\033[31m"
GRN="\033[32m"
END="\033[0m"

# ================================================== #

INFO="[INFO]"
ERROR="[ERROR]"
INFO="$GRN$INFO$END"
ERROR="$RED$ERROR$END"

# ================================================== #

log_error() {
	echo -e "$ERROR $*"
}

log_info() {
	echo -e "$INFO $*"
}

log_error_and_exit() {
	echo -e "$ERROR $*"
	exit 1
}

# ================================================== #

# Downloading Python and extracting
download_python() {
	log_info "Downloading Python version $PYTHON_VERSION..."
	wget -c $PYTHON_ARCHIVE_URL
	if [ $? -eq 0 ]; then
		log_info "Extracting $PYTHON_ARCHIVE..."
		tar -xf $PYTHON_ARCHIVE ||
			log_error_and_exit "Failed to extract python archive: $PYTHON_ARCHIVE"
	else
		log_error_and_exit "Failed to download: $PYTHON_ARCHIVE_URL"
	fi
}

# ================================================== #

# Configuring Python
configure_python() {
	log_info "Configuring Python $PYTHON_VERSION..."
	./configure --host=$TARGET_HOST --build=$BUILD_HOST --prefix=$PREFIX \
		--enable-shared \
		--enable-optimizations \
		--disable-ipv6 \
		--with-ensurepip=install \
		ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no \
		ac_cv_have_long_long_format=yes ||
		log_error_and_exit "Failed to configure Python $PYTHON_VERSION"
}

# ================================================== #

# Building Python
build_python() {
	configure_python

	log_info "Compiling Python $PYTHON_VERSION..."
	# add flags for ssl libary in makefile
	sed 's/\<lib -lssl -lcrypto\>/& -ldl -pthread/' -i Makefile
	make -j$(nproc) || log_error_and_exit "Failed to build Python $PYTHON_VERSION"
}

# ================================================== #

# Installing Python to $INSTALL_DIRECTORY
install_python() {
	make altinstall ||
		log_error_and_exit "Failed to install Python to $INSTALL_DIRECTORY"
}

# ================================================== #

# Make Debian package (.deb)
make_deb_package() {
	log_info "Building $PACKAGE_NAME.deb package..."

	mkdir -p "$PACKAGE_DIRECTORY/DEBIAN" &&
		cp control "$PACKAGE_DIRECTORY/DEBIAN"

	dpkg-deb --build $PACKAGE_DIRECTORY ||
		log_error_and_exit "Failed to make debian package"
}

# ================================================== #

main() {
	cd $WORKING_DIRECTORY

	[ ! -d "$SOURCE_DIRECTORY" ] &&
		download_python

	cd $SOURCE_DIRECTORY

	build_python

	install_python

	cd $ROOT_DIR

	make_deb_package
}

# ================================================== #

main
