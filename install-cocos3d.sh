#!/bin/bash

#
# Cocos3D 2.0.0
# Author: Bill Hollings
# Copyright (c) 2010-2014 The Brenwill Workshop Ltd. All rights reserved.
# http://www.brenwill.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# http://en.wikipedia.org/wiki/MIT_License
#

echo 'Cocos3D installer'

COCOS3D_TEMPLATE_4_DIR='Cocos3D'
BASE_TEMPLATE_4_DIR="$HOME/Library/Developer/Xcode/Templates"

usage() {
cat << EOF
Installs or updates Cocos3D Xcode templates and links Cocos2D libraries

usage: $0 [options] -2 "cocos2d-dist-dir"
 
The arg "cocos2d-dist-dir" following the -2 switch is the location of
the directory containing the Cocos2D distribution. This installer looks
for the following directories within that specified directory:
    cocos2d
	cocos2d-ui
    CocosDenshion
    CocosDenshionExtras
    external/kazmath		(Cocos2D v3 & v2 only)
 
OPTIONS:
   -h	this help
EOF
}

while getopts "fh2:" OPTION; do
	case "$OPTION" in
		h)
			usage
			exit 0
			;;
		2)
			CC2_DIST_DIR=$OPTARG
			;;
	esac
done

# Make sure Cocos2D distribution directory has been specified
if [[ ! $CC2_DIST_DIR ]]; then
	echo "Please specify the location of the Cocos2D distribution directory using the -2 switch."
	echo
	usage
	exit 1
fi

# Resolve the Cocos2D distribution directory to an absolute path
if [[ $CC2_DIST_DIR != /* ]]; then
	CC2_DIST_DIR="$PWD/$CC2_DIST_DIR"
fi

# Make sure Cocos2D distribution directory exists
if [[ ! -d "$CC2_DIST_DIR" ]];  then
	echo "The Cocos2D distribution directory '$CC2_DIST_DIR' couldn't be found!"
	exit 1
fi

#If it exists, copies the file $1 from source directory $2 to dest directory $3
copy_file() {
	if [[ -e "$2/$1" ]]; then
		echo "...copying $1"
		check_dir "$3"
		cp "$2/$1" "$3"
	fi
}

copy_files(){
	check_dir "$2"
	rsync -r --exclude=.svn "$1" "$2"
}

check_dir(){
	if [[ ! -d "$1" ]];  then
		echo ...creating destination directory: "$1"
		mkdir -p "$1"
	fi
}

# If it exists, creates a symbolic link inside the dest directory $2 to the source directory $1
# The third arg is just a description that is echoed
link_dir() {
	if [[ -d "$1" ]]; then
		echo "...linking $3"
		ln -s "$1" "$2"
	fi
}

copy_template_files(){
	DST_DIR="$TEMPLATE_DIR""$TEMPLATE"".xctemplate"
	echo ...copying $TEMPLATE template files
	copy_files "Templates/Xcode/$TEMPLATE.xctemplate/" "$DST_DIR"
}

print_template_banner(){
	echo ''
	echo "$1"
	echo '----------------------------------------------------'
	echo ''
}

# Copies Xcode project-based templates
copy_xc_project_templates() {

	print_template_banner "Installing Cocos3D Xcode templates"

	TEMPLATE_DIR="${BASE_TEMPLATE_4_DIR}/${COCOS3D_TEMPLATE_4_DIR}/"
	LEGACY_TEMPLATE_DIR="${BASE_TEMPLATE_4_DIR}/cocos3d/"

# Delete the existing Cocos3D template directory, and recreate it
	rm -rf "$TEMPLATE_DIR"

# Copy Cocos2D v1 iOS static library settings
	TEMPLATE="cocos2d-v1-stat-lib-ios"
	copy_template_files

# Copy Cocos2D v2 iOS static library settings
	TEMPLATE="cocos2d-v2-stat-lib-ios"
	copy_template_files

# Copy Cocos2D OSX static library settings
	TEMPLATE="cocos2d-v2-stat-lib-osx"
	copy_template_files

# Copy Cocos3D library files references
	TEMPLATE="cocos3d-lib"
	copy_template_files
	copy_files "cocos3d" "$DST_DIR"

# Copy Cocos3D GLSL files references
	TEMPLATE="cocos3d-glsl"
	copy_template_files
	copy_files "cocos3d-GLSL" "$DST_DIR"

# Copy base Cocos3D settings
	TEMPLATE="cocos3d-base"
	copy_template_files

# Copy Cocos3D static library settings
	TEMPLATE="cocos3d-stat-lib"
	copy_template_files
	copy_file "LICENSE_cocos3d.txt" "." "$DST_DIR"

# Copy Cocos3D static library project settings
#	TEMPLATE="Cocos3D Static Library"
#	copy_template_files

# Copy application base Cocos3D settings
	TEMPLATE="cocos3d-app-base"
	copy_template_files
	copy_file "hello-world.pod" "Models/Hello World" "$DST_DIR""/Resources"

# Copy base Cocos3D iOS app settings
	TEMPLATE="cocos3d-app-ios"
	copy_template_files
	copy_files "Projects/Common/Resources/Icons/" "$DST_DIR""/Resources"
	copy_files "Projects/Common/Resources/LaunchImages/" "$DST_DIR""/Resources"

# Copy base Cocos3D OSX settings
	TEMPLATE="cocos3d-app-osx"
	copy_template_files

# Copy base Cocos3D app project settings
	TEMPLATE="cocos3d-app-proj"
	copy_template_files

# Copy base Cocos3D iOS app project settings
	TEMPLATE="cocos3d-app-proj-ios"
	copy_template_files

# Copy base Cocos3D OSX app project settings
	TEMPLATE="cocos3d-app-proj-osx"
	copy_template_files

# Copy OpenGL ES 1 Template
	TEMPLATE="cocos3d-app-ogles1"
	copy_template_files
	copy_file "fps_images_1.png" "Projects/Common/Resources" "$DST_DIR""/Resources"

# Copy Concrete OpenGL ES 1 Application Template
	TEMPLATE="Cocos3D iOS OpenGL ES 1.1 Application"
	copy_template_files

# Copy OpenGL ES 2 Template
	TEMPLATE="cocos3d-app-ogles2"
	copy_template_files
	copy_file "fps_images.png" "Projects/Common/Resources" "$DST_DIR""/Resources"
	copy_file "fps_images-hd.png" "Projects/Common/Resources" "$DST_DIR""/Resources"
	copy_file "fps_images-ipadhd.png" "Projects/Common/Resources" "$DST_DIR""/Resources"

# Copy Concrete OpenGL ES 2 Application Template
	TEMPLATE="Cocos3D iOS OpenGL ES 2.0 Application"
	copy_template_files

# Copy OpenGL OSX Template (Cocos2D v3/v2)
	TEMPLATE="cocos3d-app-ogl"
	copy_template_files
	copy_file "fps_images.png" "Projects/Common/Resources" "$DST_DIR""/Resources"

# Copy Concrete OSX OpenGL Application Template
	TEMPLATE="Cocos3D OSX OpenGL Application"
	copy_template_files

}

link_cocos2d_libs(){
	echo
	echo "Linking to Cocos2D distribution libraries in '$CC2_DIST_DIR'."

	CC2_DIR=cocos2d

	# Remove current symbolic links and re-create new link directory
	rm -rf "$CC2_DIR"
	mkdir -p "$CC2_DIR"

	# Primary Cocos2D codebase
	link_dir "$CC2_DIST_DIR/cocos2d" "$CC2_DIR" "cocos2d"

	# Cocos2D UI code (Cocos2D v3 only)
	link_dir "$CC2_DIST_DIR/cocos2d-ui" "$CC2_DIR" "cocos2d-ui"

	copy_file "LICENSE_cocos2d.txt" "$CC2_DIST_DIR" "$CC2_DIR"

	# Kazmath library (Cocos2D v3/v2 only)
	link_dir "$CC2_DIST_DIR/external/kazmath" "$CC2_DIR" "kazmath"
	copy_file "LICENSE_Kazmath.txt" "$CC2_DIST_DIR" "$CC2_DIR"

	# Chipmunk library
	CHPMK_DIR=cocos2d-chipmunk
	rm -rf   "$CHPMK_DIR"
	CHIPMUNK_DIST_DIR="$CC2_DIST_DIR/external/Chipmunk"
	if [[ -d "$CHIPMUNK_DIST_DIR" ]]; then
		mkdir -p "$CHPMK_DIR"
		mkdir -p "$CHPMK_DIR/chipmunk"
		link_dir "$CHIPMUNK_DIST_DIR/include" "$CHPMK_DIR/chipmunk" "Chipmunk includes"
		link_dir "$CHIPMUNK_DIST_DIR/src" "$CHPMK_DIR/chipmunk" "Chipmunk source"
		link_dir "$CHIPMUNK_DIST_DIR/objectivec" "$CHPMK_DIR" "Objective Chipmunk"
	fi
	copy_file "LICENSE_Chipmunk.txt" "$CC2_DIST_DIR" "$CHPMK_DIR"

	# ObjectAL  (Cocos2D v3 only)
	link_dir "$CC2_DIST_DIR/external/ObjectAL" "$CC2_DIR" "ObjectAL"

	# CocosDenshion (Cocos2D v2/v1)
	# Depending on Cocos2D release, CocosDenshion might be in subdirectory
	CDEN_DIST_DIR="$CC2_DIST_DIR/CocosDenshion"
	if [[ -d "$CDEN_DIST_DIR/CocosDenshion" ]]; then
		link_dir "$CDEN_DIST_DIR/CocosDenshion" "$CC2_DIR" "CocosDenshion"
		link_dir "$CDEN_DIST_DIR/CocosDenshionExtras" "$CC2_DIR" "CocosDenshionExtras"
	else
		link_dir "$CDEN_DIST_DIR" "$CC2_DIR" "CocosDenshion"
	fi
	copy_file "LICENSE_CocosDenshion.txt" "$CC2_DIST_DIR" "$CC2_DIR"

	echo Finished linking Cocos2D.
}

link_cocos2d_libs

copy_xc_project_templates

echo Done!

