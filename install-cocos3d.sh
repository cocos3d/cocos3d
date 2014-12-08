#!/bin/bash

#
# Cocos3D 2.0.2
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


# ---------------------------- SETUP ----------------------------------

XCODE_TEMPLATE_DIR="$HOME/Library/Developer/Xcode/Templates"
CC2_DIR=cocos2d
CC2_CHPMK_DIR=cocos2d-chipmunk
CC2_SRC=
REZ_SRC_DIR="Projects/Common/Resources"

COLOREND=$(tput sgr0)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
UNDER=$(tput smul)
BOLD=$(tput bold)


# ---------------------------- FUNCTIONS ----------------------------------

# Outputs usage info
usage() {
cat << EOF
${BOLD}USAGE:${COLOREND}
   $0
    $0 -2 "cocos2d-location"
    $0 -h

The arg ${BOLD}"cocos2d-location"${COLOREND} following the ${BOLD}-2${COLOREND} switch is the location of
the directory containing the Cocos2D source files. This may be one of
the following psuedo-locations:

    v1
    v2
    v3

which indicates the version of Cocos2D to link to. For example:

    $0 -2 v3

will link to the Cocos2D version ${BOLD}3.x${COLOREND} template libraries that you have
most recently installed. When using a psuedo-location, you must have
previously installed the corresponding version of Cocos2D.

The arg ${BOLD}"cocos2d-location"${COLOREND} may also be a relative or absolute path
to a specific Cocos2D distribution retrieved from GitHub. For example:

    $0 -2 "../cocos2d-iphone-release-3.2"

If the ${BOLD}"cocos2d-location"${COLOREND} arg is omitted, the installer will link to the
latest installed version of Cocos2D.

${BOLD}OPTIONS${COLOREND}:
    -2 "cocos2d-location"    The path to the Cocos2D libraries
    -h                       This help

EOF
}

# Determine and verify the location of the Cocos2D source
get_cc2_location() {

	# If the Cocos2D distribution directory has not been specified, look for the most recent version
	if [[ ! $CC2_SRC ]]; then
		if [[ -d "$XCODE_TEMPLATE_DIR/cocos2d v3.x" ]]; then
			CC2_SRC="v3"
		elif [[ -d "$XCODE_TEMPLATE_DIR/cocos2d v2.x" ]]; then
			CC2_SRC="v2"
		elif [[ -d "$XCODE_TEMPLATE_DIR/cocos2d" ]]; then
			CC2_SRC="v1"
		else
			echo
			echo "${RED}✖︎${COLOREND}  A compatible version of Cocos2D does not appear to be installed. Cocos3D requires Cocos2D. See the ${BOLD}README.md${COLOREND} file for more info."
			echo
			exit 1
		fi
		echo
		echo "The version of Cocos2D to link to was not specified."
		echo "Cocos2D $CC2_SRC was found, and the Cocos3D demo apps will be linked to it."
	fi

	# Check if one of the psuedo locations is being used, and set the source location accordingly
	# The psuedo locations include the Cocos2D project templates. If not a pseudo location, take
	# the location indicate a path to the Cocos2D distribution.
	if [[ $CC2_SRC == "v3" ]]; then
		CC2_DIST_DIR="$XCODE_TEMPLATE_DIR/cocos2d v3.x"
	elif [[ $CC2_SRC == "v2" ]]; then
		CC2_DIST_DIR="$XCODE_TEMPLATE_DIR/cocos2d v2.x"
		print_version_warning
	elif [[ $CC2_SRC == "v1" ]]; then
		CC2_DIST_DIR="$XCODE_TEMPLATE_DIR/cocos2d"
		print_version_warning
	else
		CC2_DIST_DIR=$CC2_SRC
	fi

	# Resolve the Cocos2D distribution directory to an absolute path
	if [[ $CC2_DIST_DIR != /* ]]; then
		CC2_DIST_DIR="$PWD/$CC2_DIST_DIR"
		print_version_warning
	fi

	# Make sure Cocos2D distribution directory exists
	if [[ ! -d "$CC2_DIST_DIR" ]];  then
		if [[ $CC2_SRC == "v3" ]]; then
			echo
			echo "${RED}✖︎${COLOREND}  The Cocos2D v3 Xcode project template directory could not be found. Starting with ${BOLD}Cocos2D 3.2${COLOREND}, Cocos2D does not install Xcode project templates. If you are using ${BOLD}Cocos2D 3.2${COLOREND} or later, you cannot use the v3 option shortcut, and must specify the path (relative or absolute) to the Cocos2D installation directory."
			echo
		elif [[ $CC2_SRC == "v2" ]]; then
			echo
			echo "${RED}✖︎${COLOREND}  The Cocos2D v2 Xcode project template directory could not be found. Make sure you have installed this version of Cocos2D before installing Cocos3D."
			echo
		elif [[ $CC2_SRC == "v1" ]]; then
			echo
			echo "${RED}✖︎${COLOREND}  The Cocos2D v1 Xcode project template directory could not be found. Make sure you have installed this version of Cocos2D before installing Cocos3D."
			echo
		else
			echo
			echo "${RED}✖︎${COLOREND}  The Cocos2D distribution directory '$CC2_DIST_DIR' could not be found! Make sure you have specified the correct path to the Cocos2D installation directory using the -2 option."
			echo
		fi
		exit 1
	fi

}

print_version_warning() {
	echo
	echo "${BOLD}You are linking the Cocos3D demo apps to Cocos2D $CC2_SRC. Please see the README.md file for instructions on configuring the Cocos3D demo apps to use this version of Cocos2D.${COLOREND}"
}

# Outputs a banner header
print_banner(){
	echo ''
	echo "$1"
	echo '----------------------------------------------------'
}

print_ok() {
	printf " ${GREEN}✔${COLOREND}\n"
}

#If it exists, copies the file $1 from source directory $2 to dest directory $3
copy_file() {
	if [[ -e "$2/$1" ]]; then
		check_dir "$3"
		echo -n "...copying $1..."
		cp "$2/$1" "$3"
		print_ok
	fi
}

# Copies files in directory $1 to $2, creating the destination directory if needed.
# Arg $3 is used to output user feedback about what is being copied.
copy_files(){
	check_dir "$2"
	echo -n "...copying $3..."
	rsync -r "$1" "$2"
	print_ok
}

# Copies files in directory $1 to $2, deleting and recreating the directory in the process.
# Symbolic links are resolved and the underlying files copied.
# Arg $3 is used to output user feedback about what is being copied.
replace_dir_resolve_simlinks(){
	echo -n "...copying $3..."
	rm -rf "$2"
	mkdir -p "$2"
	cp -pRL "$1" "$2"
	print_ok
}

check_dir(){
	if [[ ! -d "$1" ]];  then
		mkdir -p "$1"
	fi
}

# If it exists, creates a symbolic link inside the dest directory $2 to the source directory $1
# The third arg is just a description that is echoed
link_dir() {
	if [[ -d "$1" ]]; then
		echo -n "...linking $3..."
		ln -s "$1" "$2"
		print_ok
	fi
}

# Copies Cocos3D Xcode project templates
copy_project_templates() {

	print_banner "Installing Cocos3D Xcode templates"

	CC3_TEMPLATE_DIR="$XCODE_TEMPLATE_DIR/Cocos3D"
	TEMPLATE_SRC_DIR="Templates/Xcode"
	SUPPORT_DIR="Support"
	BASE_DIR="$SUPPORT_DIR/Base"
	BUNDLE_DIR="$SUPPORT_DIR/Bundle"
	STAT_LIB_DIR="$SUPPORT_DIR/StatLib"

# Delete the existing Cocos3D template directory, and recreate it
	echo -n "...removing existing Cocos3D template files..."
	rm -rf "$CC3_TEMPLATE_DIR"
	rm -rf "$XCODE_TEMPLATE_DIR/cocos3d"	# Delete legacy folder
	mkdir -p "$CC3_TEMPLATE_DIR"
	print_ok

# Copy new Cocos3D support template files
	copy_files "$TEMPLATE_SRC_DIR/$SUPPORT_DIR" "$CC3_TEMPLATE_DIR" "Cocos3D template support files"

# Copy app templates for Cocos2D v3
	if [[ -d "$XCODE_TEMPLATE_DIR/cocos2d v3.x" ]]; then
		SRC_DIR="$TEMPLATE_SRC_DIR/cocos3d-app-proj-cocos2d-v3-ios.xctemplate"
		copy_files "$SRC_DIR" "$CC3_TEMPLATE_DIR" "Cocos3D iOS App with Cocos2D-v3 template"
		SRC_DIR="$TEMPLATE_SRC_DIR/cocos3d-app-proj-cocos2d-v3-osx.xctemplate"
		copy_files "$SRC_DIR" "$CC3_TEMPLATE_DIR" "Cocos3D OSX App with Cocos2D-v3 template"
	fi

# Copy app templates for Cocos2D v2
	if [[ -d "$XCODE_TEMPLATE_DIR/cocos2d v2.x" ]]; then
		SRC_DIR="$TEMPLATE_SRC_DIR/cocos3d-app-proj-cocos2d-v2-ios.xctemplate"
		copy_files "$SRC_DIR" "$CC3_TEMPLATE_DIR" "Cocos3D iOS App with Cocos2D-v2 template"
		SRC_DIR="$TEMPLATE_SRC_DIR/cocos3d-app-proj-cocos2d-v2-osx.xctemplate"
		copy_files "$SRC_DIR" "$CC3_TEMPLATE_DIR" "Cocos3D OSX App with Cocos2D-v2 template"
	fi

# Copy app templates for Cocos2D v1
	if [[ -d "$XCODE_TEMPLATE_DIR/cocos2d" ]]; then
		SRC_DIR="$TEMPLATE_SRC_DIR/cocos3d-app-proj-cocos2d-v1-ios.xctemplate"
		copy_files "$SRC_DIR" "$CC3_TEMPLATE_DIR" "Cocos3D iOS App with Cocos2D-v1 template"
	fi

# Copy static library templates
	SRC_DIR="$TEMPLATE_SRC_DIR/cocos3d-stat-lib-proj-ios.xctemplate"
	copy_files "$SRC_DIR" "$CC3_TEMPLATE_DIR" "Cocos3D iOS Static Library"
	SRC_DIR="$TEMPLATE_SRC_DIR/cocos3d-stat-lib-proj-osx.xctemplate"
	copy_files "$SRC_DIR" "$CC3_TEMPLATE_DIR" "Cocos3D OSX Static Library"

# Copy Cocos3D library files
	TEMPLATE="$BASE_DIR/cocos3d-lib"
	DST_DIR="$CC3_TEMPLATE_DIR/$TEMPLATE.xctemplate"
	copy_files "cocos3d" "$DST_DIR" "Cocos3D source files"

# Copy Cocos3D GLSL files
	TEMPLATE="$BASE_DIR/cocos3d-glsl"
	DST_DIR="$CC3_TEMPLATE_DIR/$TEMPLATE.xctemplate"
	copy_files "cocos3d-GLSL" "$DST_DIR" "Cocos3D GLSL source files"

# Copy Cocos3D licenses
	TEMPLATE="$STAT_LIB_DIR/cocos3d-stat-lib"
	DST_DIR="$CC3_TEMPLATE_DIR/$TEMPLATE.xctemplate"
	copy_file "LICENSE_cocos3d.txt" "." "$DST_DIR"

	TEMPLATE="$STAT_LIB_DIR/cocos3d-resource-bundle"
	DST_DIR="$CC3_TEMPLATE_DIR/$TEMPLATE.xctemplate"
	copy_file "LICENSE_cocos3d.txt" "." "$DST_DIR"

# Copy application model assets
	TEMPLATE="$BUNDLE_DIR/cocos3d-app-base"
	DST_DIR="$CC3_TEMPLATE_DIR/$TEMPLATE.xctemplate/Resources"
	copy_file "hello-world.pod" "Models/Hello World" "$DST_DIR"

# Copy icons and launch images
	TEMPLATE="$BUNDLE_DIR/cocos3d-app-ios"
	DST_DIR="$CC3_TEMPLATE_DIR/$TEMPLATE.xctemplate/Resources"
	copy_files "$REZ_SRC_DIR/Icons" "$DST_DIR" "icons"
	copy_files "$REZ_SRC_DIR/LaunchImages" "$DST_DIR" "launch images"

# Copy Cocos2D iOS FPS images
	TEMPLATE="$BUNDLE_DIR/cocos3d-app-ios"
	DST_DIR="$CC3_TEMPLATE_DIR/$TEMPLATE.xctemplate/Resources"
	copy_file "fps_images.png" "$REZ_SRC_DIR" "$DST_DIR"
	copy_file "fps_images-hd.png" "$REZ_SRC_DIR" "$DST_DIR"
	copy_file "fps_images-ipadhd.png" "$REZ_SRC_DIR" "$DST_DIR"
	copy_file "fps_images_1.png" "$REZ_SRC_DIR" "$DST_DIR"

# Copy Cocos2D OSX FPS images
	TEMPLATE="$BUNDLE_DIR/cocos3d-app-osx"
	DST_DIR="$CC3_TEMPLATE_DIR/$TEMPLATE.xctemplate/Resources"
	copy_file "fps_images.png" "$REZ_SRC_DIR" "$DST_DIR"

	echo Finished installing Cocos3D Xcode templates.
}

# Remove current links and re-create new link directory
clear_cocos2d_links() {
	echo -n "...removing existing Cocos2D links..."
	rm -rf "$CC2_DIR"
	mkdir -p "$CC2_DIR"
	rm -rf   "$CC2_CHPMK_DIR"
	mkdir -p "$CC2_CHPMK_DIR"
	mkdir -p "$CC2_CHPMK_DIR/chipmunk"
	print_ok
}

# Links to the Cocos2D libraries in the Cocos2d v1 templates
link_cocos2d_templates_v1() {
	print_banner "Linking Cocos3D demo apps to installed Cocos2D v1 libraries in '$CC2_DIST_DIR'."

	# Remove current links and re-create new link directory
	clear_cocos2d_links

	# Primary Cocos2D codebase and license
	SRC_DIR="$CC2_DIST_DIR/lib_cocos2d.xctemplate/libs"
	link_dir "$SRC_DIR/cocos2d" "$CC2_DIR" "cocos2d"
	copy_file "LICENSE_cocos2d.txt" "$SRC_DIR" "$CC2_DIR"

	# CocosDenshion
	SRC_DIR="$CC2_DIST_DIR/lib_cocosdenshion.xctemplate/libs"
	link_dir "$SRC_DIR/CocosDenshion" "$CC2_DIR" "CocosDenshion"
	copy_file "LICENSE_CocosDenshion.txt" "$SRC_DIR" "$CC2_DIR"

	# CocosDenshion Extras
	SRC_DIR="$CC2_DIST_DIR/lib_cocosdenshionextras.xctemplate/libs"
	link_dir "$SRC_DIR/CocosDenshionExtras" "$CC2_DIR" "CocosDenshion Extras"

	# FontLabel
	SRC_DIR="$CC2_DIST_DIR/lib_fontlabel.xctemplate/libs"
	link_dir "$SRC_DIR/FontLabel" "$CC2_DIR" "FontLabel"
	copy_file "LICENSE_FontLabel.txt" "$SRC_DIR" "$CC2_DIR"

	# Chipmunk library
	SRC_DIR="$CC2_DIST_DIR/lib_chipmunk.xctemplate/libs"
	link_dir "$SRC_DIR/Chipmunk/include" "$CC2_CHPMK_DIR/chipmunk" "Chipmunk includes"
	link_dir "$SRC_DIR/Chipmunk/src" "$CC2_CHPMK_DIR/chipmunk" "Chipmunk source"
	copy_file "LICENSE_Chipmunk.txt" "$SRC_DIR" "$CC2_CHPMK_DIR"

}

# Links to the Cocos2D libraries in the Cocos2d v2 templates
link_cocos2d_templates_v2() {
	print_banner "Linking Cocos3D demo apps to installed Cocos2D v2 libraries in '$CC2_DIST_DIR'."

	# Remove current links and re-create new link directory
	clear_cocos2d_links

	# Primary Cocos2D codebase and license
	SRC_DIR="$CC2_DIST_DIR/lib_cocos2d.xctemplate/libs"
	link_dir "$SRC_DIR/cocos2d" "$CC2_DIR" "cocos2d"
	copy_file "LICENSE_cocos2d.txt" "$SRC_DIR" "$CC2_DIR"

	# Kazmath library
	SRC_DIR="$CC2_DIST_DIR/lib_kazmath.xctemplate/libs"
	link_dir "$SRC_DIR/kazmath" "$CC2_DIR" "kazmath"
	copy_file "LICENSE_Kazmath.txt" "$SRC_DIR" "$CC2_DIR"

	# CocosDenshion
	SRC_DIR="$CC2_DIST_DIR/lib_cocosdenshion.xctemplate/libs"
	link_dir "$SRC_DIR/CocosDenshion" "$CC2_DIR" "CocosDenshion"
	copy_file "LICENSE_CocosDenshion.txt" "$SRC_DIR" "$CC2_DIR"

	# Chipmunk library
	SRC_DIR="$CC2_DIST_DIR/lib_chipmunk.xctemplate/libs"
	link_dir "$SRC_DIR/Chipmunk/include" "$CC2_CHPMK_DIR/chipmunk" "Chipmunk includes"
	link_dir "$SRC_DIR/Chipmunk/src" "$CC2_CHPMK_DIR/chipmunk" "Chipmunk source"
	copy_file "LICENSE_Chipmunk.txt" "$SRC_DIR" "$CC2_CHPMK_DIR"

}

# Links to the Cocos2D libraries in the Cocos2d v3 templates
link_cocos2d_templates_v3() {
	print_banner "Linking Cocos3D demo apps to installed Cocos2D v3 libraries in '$CC2_DIST_DIR'."

	# Remove current links and re-create new link directory
	clear_cocos2d_links

	# Primary Cocos2D code and license
	SRC_DIR="$CC2_DIST_DIR/Support/Libraries/lib_cocos2d.xctemplate/Libraries"
	link_dir "$SRC_DIR/cocos2d" "$CC2_DIR" "cocos2d"
	copy_file "LICENSE_cocos2d.txt" "$SRC_DIR" "$CC2_DIR"

	# Cocos2D UI code
	SRC_DIR="$CC2_DIST_DIR/Support/Libraries/lib_cocos2d-ui.xctemplate/Libraries"
	link_dir "$SRC_DIR/cocos2d-ui" "$CC2_DIR" "cocos2d-ui"

	# CCBReader code and license
	SRC_DIR="$CC2_DIST_DIR/Support/Libraries/lib_ccbreader.xctemplate/Libraries"
	link_dir "$SRC_DIR/CCBReader" "$CC2_DIR" "cocos2d"
	copy_file "LICENSE_CCBReader.txt" "$SRC_DIR" "$CC2_DIR"

	# ObjectAL library
	SRC_DIR="$CC2_DIST_DIR/Support/Libraries/lib_objectal.xctemplate/Libraries"
	link_dir "$SRC_DIR/ObjectAL" "$CC2_DIR" "ObjectAL"

	# Chipmunk library and license
	SRC_DIR="$CC2_DIST_DIR/Support/Libraries/lib_chipmunk.xctemplate/Libraries"
	link_dir "$SRC_DIR/Chipmunk/chipmunk/include" "$CC2_CHPMK_DIR/chipmunk" "Chipmunk includes"
	link_dir "$SRC_DIR/Chipmunk/chipmunk/src" "$CC2_CHPMK_DIR/chipmunk" "Chipmunk source"
	link_dir "$SRC_DIR/Chipmunk/objectivec" "$CC2_CHPMK_DIR" "Objective Chipmunk"
	copy_file "LICENSE_Chipmunk.txt" "$SRC_DIR" "$CC2_CHPMK_DIR"

	# Kazmath library and license (Cocos2D 3.0 only)
	SRC_DIR="$CC2_DIST_DIR/Support/Libraries/lib_kazmath.xctemplate/Libraries"
	link_dir "$SRC_DIR/kazmath" "$CC2_DIR" "kazmath"
	copy_file "LICENSE_Kazmath.txt" "$SRC_DIR" "$CC2_DIR"

}

# Links to the Cocos2D libraries in a specific Cocos2D distribution directory
link_cocos2d_distribution() {

	print_banner "Linking Cocos3D demo apps to Cocos2D distribution libraries in '$CC2_DIST_DIR'."

	# Remove current links and re-create new link directory
	clear_cocos2d_links

	# Primary Cocos2D codebase
	link_dir "$CC2_DIST_DIR/cocos2d" "$CC2_DIR" "cocos2d"

	# Cocos2D UI code (Cocos2D v3 only)
	link_dir "$CC2_DIST_DIR/cocos2d-ui" "$CC2_DIR" "cocos2d-ui"

	copy_file "LICENSE_cocos2d.txt" "$CC2_DIST_DIR" "$CC2_DIR"

	# Kazmath library (Cocos2D v3/v2 only)
	link_dir "$CC2_DIST_DIR/external/kazmath" "$CC2_DIR" "kazmath"
	copy_file "LICENSE_Kazmath.txt" "$CC2_DIST_DIR" "$CC2_DIR"

	# Chipmunk library
	CHIPMUNK_DIST_DIR="$CC2_DIST_DIR/external/Chipmunk"
	link_dir "$CHIPMUNK_DIST_DIR/include" "$CC2_CHPMK_DIR/chipmunk" "Chipmunk includes"
	link_dir "$CHIPMUNK_DIST_DIR/src" "$CC2_CHPMK_DIR/chipmunk" "Chipmunk source"
	link_dir "$CHIPMUNK_DIST_DIR/objectivec" "$CC2_CHPMK_DIR" "Objective Chipmunk"
	copy_file "LICENSE_Chipmunk.txt" "$CC2_DIST_DIR" "$CC2_CHPMK_DIR"

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
}

# Links to the Cocos2D libraries
link_cocos2d_libs() {

	if [[ $CC2_SRC == "v1" ]]; then
		link_cocos2d_templates_v1
	elif [[ $CC2_SRC == "v2" ]]; then
		link_cocos2d_templates_v2
	elif [[ $CC2_SRC == "v3" ]]; then
		link_cocos2d_templates_v3
	else
		link_cocos2d_distribution
	fi

	echo Finished linking Cocos2D.
}

# Copies the library directories and resources to the hello, world template project
copy_to_template() {
	CC3_HW_DIR="Projects/CC3HelloWorld"
	CC3_HW_REZ_DIR="$CC3_HW_DIR/ProjectFiles/Resources"
	CC3_HW_NAME="Hello World template project"

	# Copy Cocos2D & Cocos3D library folders to project
	replace_dir_resolve_simlinks "$CC2_DIR/" "$CC3_HW_DIR/cocos2d" "Cocos2D to the $CC3_HW_NAME"
	replace_dir_resolve_simlinks "$CC2_CHPMK_DIR/" "$CC3_HW_DIR/cocos2d-chipmunk" "Cocos2D Chipmunk to the $CC3_HW_NAME"
	replace_dir_resolve_simlinks "cocos3d/" "$CC3_HW_DIR/cocos3d" "Cocos3D to the $CC3_HW_NAME"
	copy_file "LICENSE_cocos3d.txt" "." "$CC3_HW_DIR"

	# Copy default shaders, resources and images to project
	replace_dir_resolve_simlinks "cocos3d-GLSL/" "$CC3_HW_DIR/ProjectFiles/cocos3d-GLSL" "Cocos3D default shaders to the $CC3_HW_NAME"
	replace_dir_resolve_simlinks "Projects/Common/Images-iOS.xcassets/" "$CC3_HW_DIR/ProjectFiles/iOS Support/Images-iOS.xcassets" "iOS app icons to the $CC3_HW_NAME"
	replace_dir_resolve_simlinks "Projects/Common/Images-OSX.xcassets/" "$CC3_HW_DIR/ProjectFiles/OSX Support/Images-OSX.xcassets" "OSX app icons to the $CC3_HW_NAME"

	echo -n "...copying resources to the $CC3_HW_NAME..."
	check_dir "$CC3_HW_REZ_DIR"
	copy_file "hello-world.pod" "Models/Hello World" "$CC3_HW_REZ_DIR"
	copy_file "BrushedSteel.png" "$REZ_SRC_DIR/Masks" "$CC3_HW_REZ_DIR"
	copy_file "fps_images.png" "$REZ_SRC_DIR" "$CC3_HW_REZ_DIR"
	copy_file "fps_images_1.png" "$REZ_SRC_DIR" "$CC3_HW_REZ_DIR"
	copy_file "fps_images-hd.png" "$REZ_SRC_DIR" "$CC3_HW_REZ_DIR"
	copy_file "fps_images-ipadhd.png" "$REZ_SRC_DIR" "$CC3_HW_REZ_DIR"
	print_ok
}

# Copies the library directories to the static library template project
copy_to_statlib() {
	CC3_SL_DIR="Projects/CC3StatLib"
	CC3_SL_NAME="Cocos3D static library template project"

	replace_dir_resolve_simlinks "cocos3d/" "$CC3_SL_DIR/cocos3d" "Cocos3D to the $CC3_SL_NAME"
	replace_dir_resolve_simlinks "cocos3d-GLSL/" "$CC3_SL_DIR/cocos3d-GLSL" "Cocos3D default shaders to the $CC3_SL_NAME"
	copy_file "LICENSE_cocos3d.txt" "." "$CC3_SL_DIR"
}


# ----------------------------MAIN ENTRY POINT ----------------------------------

# Retrieve the command arguments
while getopts "h2:" OPTION; do
	case "$OPTION" in
		h)
			echo
			echo ${BOLD}Installs Cocos3D Xcode templates and links to the Cocos2D libraries.${COLOREND}
			echo
			usage
			exit 0
		;;

		2)
			CC2_SRC=$OPTARG
		;;
	esac
done

echo
echo "${BOLD}Installing Cocos3D...${COLOREND}"

get_cc2_location

copy_project_templates

link_cocos2d_libs

copy_to_template

copy_to_statlib

echo
printf "${GREEN}✔${COLOREND} ${BOLD}Done!${COLOREND}\n"
echo

