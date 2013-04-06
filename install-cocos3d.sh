#!/bin/bash

#
# cocos3d 2.0.0
# Author: Bill Hollings
# Copyright (c) 2010-2013 The Brenwill Workshop Ltd. All rights reserved.
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

echo 'cocos3d installer'

COCOS3D_TEMPLATE_4_DIR='cocos3d'
BASE_TEMPLATE_4_DIR="$HOME/Library/Developer/Xcode/Templates"

force=

usage() {
cat << EOF
Installs or updates cocos3d Xcode templates and links cocos2d libraries

usage: $0 [options] -2 "cocos2d-dist-dir"
 
The arg "cocos2d-dist-dir" following the -2 switch is the location of
the directory containing the cocos2d distribution. This installer looks
for the following directories within that specified directory:
    cocos2d
    CocosDenshion
    CocosDenshionExtras
    external/kazmath		(cocos2d 2.x only)
 
OPTIONS:
   -f	force existing template directories to be ovewritten
   -h	this help
EOF
}

while getopts "fh2:" OPTION; do
	case "$OPTION" in
		f)
			force=1
			;;
		h)
			usage
			exit 0
			;;
		2)
			CC2_DIST_DIR=$OPTARG
			;;
	esac
done

# Make sure cocos2d distribution directory has been specified
if [[ ! $CC2_DIST_DIR ]]; then
	echo "Please specify the location of the cocos2d distribution directory using the -2 switch."
	echo
	usage
	exit 1
fi

# Resolve the cocos2d distribution directory to an absolute path
if [[ $CC2_DIST_DIR != /* ]]; then
	CC2_DIST_DIR="$PWD/$CC2_DIST_DIR"
fi

# Make sure cocos2d distribution directory exists
if [[ ! -d "$CC2_DIST_DIR" ]];  then
	echo "The cocos2d distribution directory '$CC2_DIST_DIR' couldn't be found!"
	exit 1
fi

copy_files(){
	rsync -r --exclude=.svn "$1" "$2"
}

check_dst_dir(){
	if [[ -d $DST_DIR ]];  then
		if [[ $force ]]; then
			echo "...removing old template: ${DST_DIR}"
			rm -rf "$DST_DIR"
		else
			echo "Template ${DST_DIR} already installed. To force a re-install use the '-f' parameter"
			exit 1
		fi
	fi
	
	echo ...creating destination directory: $DST_DIR
	mkdir -p "$DST_DIR"
}

print_template_banner(){
	echo ''
	echo "$1"
	echo '----------------------------------------------------'
	echo ''
}

# Copies Xcode 4 project-based templates
copy_xc4_project_templates(){
	TEMPLATE_DIR="${BASE_TEMPLATE_4_DIR}/${COCOS3D_TEMPLATE_4_DIR}/"

# If the cocos3d template directory does not exist, create it.
	if [[ ! -d "$TEMPLATE_DIR" ]]; then
		echo '...creating Xcode 4 cocos3d template folder'
		echo ''
		mkdir -p "$TEMPLATE_DIR"
	fi

	print_template_banner "Installing Xcode 4 cocos3d iOS template"

# Remove any pre-cocos3d-2.0 templates
	rm -rf "$TEMPLATE_DIR""cocos3d Application.xctemplate"

# Copy OpenGL ES 1 Template
	TEMPLATE="cocos3d iOS Application"
	DST_DIR="$TEMPLATE_DIR""cocos3d1 iOS Application.xctemplate"
	check_dst_dir
	echo ...copying $TEMPLATE template files for use with OpenGL ES 1.1
	copy_files "Templates/Xcode4/$TEMPLATE.xctemplate/" "$DST_DIR"

	mv "$DST_DIR/TemplateInfo1.plist" "$DST_DIR/TemplateInfo.plist"
	rm "$DST_DIR/TemplateInfo2.plist"

	DST_DIR="$DST_DIR""/Resources"
	check_dst_dir
	copy_files "Demos/Common/Resources/hello-world.pod" "$DST_DIR"
	copy_files "Demos/Common/Resources/fps_images_1.png" "$DST_DIR"

# Copy OpenGL ES 2 Template
	TEMPLATE="cocos3d iOS Application"
	DST_DIR="$TEMPLATE_DIR""cocos3d2 iOS Application.xctemplate"
	check_dst_dir
	echo ...copying $TEMPLATE template files for use with OpenGL ES 2.0
	copy_files "Templates/Xcode4/$TEMPLATE.xctemplate/" "$DST_DIR"

	mv "$DST_DIR/TemplateInfo2.plist" "$DST_DIR/TemplateInfo.plist"
	rm "$DST_DIR/TemplateInfo1.plist"

	DST_DIR="$DST_DIR""/Resources"
	check_dst_dir
	copy_files "Demos/Common/Resources/hello-world.pod" "$DST_DIR"

# Copy OpenGL Mac Template (cocos2d 1.x)
	TEMPLATE="cocos3d Mac Application"
	DST_DIR="$TEMPLATE_DIR""cocos3d1 Mac Application.xctemplate"
	check_dst_dir
	echo ...copying $TEMPLATE template files for use with OpenGL under OSX and cocos2d 1.x
	copy_files "Templates/Xcode4/$TEMPLATE.xctemplate/" "$DST_DIR"

	mv "$DST_DIR/TemplateInfo1.plist" "$DST_DIR/TemplateInfo.plist"
	rm "$DST_DIR/TemplateInfo2.plist"

	DST_DIR="$DST_DIR""/Resources"
	check_dst_dir
	copy_files "Demos/Common/Resources/hello-world.pod" "$DST_DIR"

# Copy OpenGL Mac Template (cocos2d 2.x)
	TEMPLATE="cocos3d Mac Application"
	DST_DIR="$TEMPLATE_DIR""cocos3d2 Mac Application.xctemplate"
	check_dst_dir
	echo ...copying $TEMPLATE template files for use with OpenGL under OSX and cocos2d 2.x
	copy_files "Templates/Xcode4/$TEMPLATE.xctemplate/" "$DST_DIR"

	mv "$DST_DIR/TemplateInfo2.plist" "$DST_DIR/TemplateInfo.plist"
	rm "$DST_DIR/TemplateInfo1.plist"

	DST_DIR="$DST_DIR""/Resources"
	check_dst_dir
	copy_files "Demos/Common/Resources/hello-world.pod" "$DST_DIR"

# Copy Base cocos3d project settings
	TEMPLATE="cocos3d-base"
	DST_DIR="$TEMPLATE_DIR""$TEMPLATE.xctemplate"
	check_dst_dir
	echo ...copying $TEMPLATE template files
	copy_files "Templates/Xcode4/$TEMPLATE.xctemplate/" "$DST_DIR"

# Copy Base cocos3d Mac project settings
	TEMPLATE="cocos3d-base-mac"
	DST_DIR="$TEMPLATE_DIR""$TEMPLATE.xctemplate"
	check_dst_dir
	echo ...copying $TEMPLATE template files
	copy_files "Templates/Xcode4/$TEMPLATE.xctemplate/" "$DST_DIR"

# Copy cocos3d library files references
	TEMPLATE="cocos3d-lib"
	DST_DIR="$TEMPLATE_DIR""$TEMPLATE.xctemplate"
	check_dst_dir
	echo ...copying $TEMPLATE template files
	copy_files "Templates/Xcode4/$TEMPLATE.xctemplate/" "$DST_DIR"

	echo ...copying cocos3d files to $TEMPLATE template
	copy_files "cocos3d" "$DST_DIR"

	echo done!
}

# If it exists, creates a symbolic link inside the dest directory $2 to the source directory $1
# The third arg is just a description that is echoed
link_dir(){
if [[ -d "$1" ]]; then
	echo "...linking $3"
	ln -s "$1" "$2"
fi
}

link_cocos2d_libs(){
	echo
	echo "Linking to cocos2d distribution libraries in '$CC2_DIST_DIR'."

	CC2_DIR=cocos2d

	rm -rf "$CC2_DIR"
	mkdir -p "$CC2_DIR"

	link_dir "$CC2_DIST_DIR/cocos2d" "$CC2_DIR" "cocos2d"

	# Depending on cocos2d release, CocosDenshion might be in subdirectory
	CDEN_DIST_DIR="$CC2_DIST_DIR/CocosDenshion"
	if [[ -d "$CDEN_DIST_DIR/CocosDenshion" ]]; then
		link_dir "$CDEN_DIST_DIR/CocosDenshion" "$CC2_DIR" "CocosDenshion"
		link_dir "$CDEN_DIST_DIR/CocosDenshionExtras" "$CC2_DIR" "CocosDenshionExtras"
	else
		link_dir "$CDEN_DIST_DIR" "$CC2_DIR" "CocosDenshion"
	fi

	link_dir "$CC2_DIST_DIR/external/kazmath" "$CC2_DIR" "kazmath (cocos2d 2.x only)"

	echo done!
}

link_cocos2d_libs

copy_xc4_project_templates

