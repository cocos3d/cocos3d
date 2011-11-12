#!/bin/bash

# cocos3d 0.6.3

echo 'cocos3d installer'

COCOS3D_TEMPLATE_4_DIR='cocos3d'
BASE_TEMPLATE_4_DIR="$HOME/Library/Developer/Xcode/Templates"
BASE_TEMPLATE_4_USER_DIR="$HOME/Library/Developer/Xcode/Templates"

force=
user_dir=

usage(){
cat << EOF
Install / update templates for cocos3d

usage: $0 [options] -2 "cocos2d-dist-dir"
 
The arg "cocos2d-dist-dir" following the -2 switch is the location of
the directory containing the cocos2d distribution. This installer looks
for the following directories within that specified directory:
    cocos2d
    CocosDenshion
    cocoslive
    external/FontLabel
    external/TouchJSON
 
OPTIONS:
   -u	install in user's Library directory instead of global directory
   -f	force overwrite if directories exist
   -h	this help
EOF
}

while getopts "fhu2:" OPTION; do
	case "$OPTION" in
		f)
			force=1
			;;
		h)
			usage
			exit 0
			;;
		u)
			user_dir=1
			;;
		2)
			c2d_dist_dir=$OPTARG
			;;
	esac
done

# Make sure cocos2d distribution directory has been specified
if [[ ! $c2d_dist_dir ]]; then
	echo "Please specify the location of the cocos2d distribution directory using the -2 switch."
	echo
	usage
	exit 1
fi

# Make sure cocos2d distribution directory exists
if [[ ! -d "$c2d_dist_dir" ]];  then
	echo "The cocos2d distribution directory '$c2d_dist_dir' couldn't be found!"
	exit 1
fi

# Make sure only root can run our script
if [[ ! $user_dir  && "$(id -u)" != "0" ]]; then
	echo ""
	echo "This script must be run as root in order to copy templates to ${BASE_TEMPLATE_DIR}" 1>&2
	echo ""
	echo "Try running it with 'sudo', or with '-u' to install it only you:" 1>&2
	echo "   sudo $0" 1>&2
	echo "or:" 1>&2
	echo "   $0 -u" 1>&2   
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

copy_base_mac_files(){
	echo ...copying cocos2d files
	copy_files "$c2d_dist_dir/cocos2d" "$LIBS_DIR"

	echo ...copying CocosDenshion files
	copy_files "$c2d_dist_dir/CocosDenshion" "$LIBS_DIR"
}

copy_base_files(){
	echo ...copying cocos2d files
	copy_files "$c2d_dist_dir/cocos2d" "$LIBS_DIR"

	echo ...copying cocos2d dependency files
	copy_files "$c2d_dist_dir/external/FontLabel" "$LIBS_DIR"

	echo ...copying CocosDenshion files
	copy_files "$c2d_dist_dir/CocosDenshion/CocosDenshion" "$LIBS_DIR"

	echo ...copying cocoslive files
	copy_files "$c2d_dist_dir/cocoslive" "$LIBS_DIR"

	echo ...copying cocoslive dependency files
	copy_files "$c2d_dist_dir/external/TouchJSON" "$LIBS_DIR"
}

print_template_banner(){
	echo ''
	echo "$1"
	echo '----------------------------------------------------'
	echo ''
}

# copies Xcode 4 project-based templates
copy_xc4_project_templates(){
	if [[ $user_dir ]]; then
		TEMPLATE_DIR="${BASE_TEMPLATE_4_USER_DIR}/${COCOS3D_TEMPLATE_4_DIR}/"
	else
		TEMPLATE_DIR="${BASE_TEMPLATE_4_DIR}/${COCOS3D_TEMPLATE_4_DIR}/"
	fi

	if [[ ! -d "$TEMPLATE_DIR" ]]; then
		echo '...creating Xcode 4 cocos3d template folder'
		echo ''
		mkdir -p "$TEMPLATE_DIR"
	fi

	print_template_banner "Installing Xcode 4 cocos3d iOS template"

	TEMPLATE="cocos3d Application"
	DST_DIR="$TEMPLATE_DIR""$TEMPLATE.xctemplate"
	check_dst_dir
	echo ...copying $TEMPLATE template files
	copy_files "Templates/Xcode4/$TEMPLATE.xctemplate/" "$DST_DIR"

	DST_DIR="$DST_DIR""/Resources"
	check_dst_dir
	copy_files "Demos/Common/Resources/hello-world.pod" "$DST_DIR"

	TEMPLATE="cocos3d-base"
	DST_DIR="$TEMPLATE_DIR""$TEMPLATE.xctemplate"
	check_dst_dir
	echo ...copying $TEMPLATE template files
	copy_files "Templates/Xcode4/$TEMPLATE.xctemplate/" "$DST_DIR"

	TEMPLATE="cocos3d-lib"
	DST_DIR="$TEMPLATE_DIR""$TEMPLATE.xctemplate"
	check_dst_dir
	echo ...copying $TEMPLATE template files
	copy_files "Templates/Xcode4/$TEMPLATE.xctemplate/" "$DST_DIR"

	echo ...copying cocos3d files to $TEMPLATE template
	copy_files cocos3d "$DST_DIR"

	echo done!
}

copy_cocos2d_libs(){
	echo
	echo Copying coocs2d libraries to workspace
	LIBS_DIR=libs
	copy_base_files
	echo done!
}

copy_cocos2d_libs

copy_xc4_project_templates

