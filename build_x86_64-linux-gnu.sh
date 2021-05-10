#!/bin/bash

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
TARGET_HOST="x86_64-linux-gnu"

WORKING_DIRECTORY="$(pwd)/build/$TARGET_HOST"
mkdir -p $WORKING_DIRECTORY

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

configure_python() {
	log_info "Configuring Python $PYTHON_VERSION..."
	./configure \
		--enable-shared \
		--enable-optimizations ||
		log_error_and_exit "Failed to configure Python $PYTHON_VERSION"
}

# ================================================== #

build_python() {
	configure_python

	log_info "Compiling Python $PYTHON_VERSION..."
	make -j$(nproc) build_all || log_error_and_exit "Failed to build Python $PYTHON_VERSION"
}

# ================================================== #

install_python() {
	make install ||
		log_error_and_exit "Failed to install Python to $INSTALL_DIRECTORY"
}

# ================================================== #

main() {
	cd $WORKING_DIRECTORY

	[ ! -d "$SOURCE_DIRECTORY" ] &&
		download_python

	cd $SOURCE_DIRECTORY

	build_python

	install_python
}

# ================================================== #

main
