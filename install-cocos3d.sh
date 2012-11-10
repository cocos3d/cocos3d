#!/bin/bash

# cocos3d 0.7.2

echo 'cocos3d installer'

COCOS3D_TEMPLATE_4_DIR='cocos3d'
BASE_TEMPLATE_4_DIR="$HOME/Library/Developer/Xcode/Templates"

force=

usage(){
cat << EOF
Install or update Xcode templates and link external libraries for cocos3d

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
   -f	force overwrite if template directories exist
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

# copies Xcode 4 project-based templates
copy_xc4_project_templates(){
	TEMPLATE_DIR="${BASE_TEMPLATE_4_DIR}/${COCOS3D_TEMPLATE_4_DIR}/"

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

link_cocos2d_libs(){
	echo
	echo Linking cocos2d libraries to workspace
	CC2_DIR=cocos2d

	rm -rf "$CC2_DIR"
	mkdir -p "$CC2_DIR"

	echo ...linking cocos2d files
	ln -s "$c2d_dist_dir/cocos2d" "$CC2_DIR"

	echo ...linking FontLabel files
	ln -s "$c2d_dist_dir/external/FontLabel" "$CC2_DIR"

	echo ...linking CocosDenshion files
	ln -s "$c2d_dist_dir/CocosDenshion/CocosDenshion" "$CC2_DIR"

	echo ...linking cocoslive files
	ln -s "$c2d_dist_dir/cocoslive" "$CC2_DIR"

	echo ...linking cocoslive dependency files
	ln -s "$c2d_dist_dir/external/TouchJSON" "$CC2_DIR"

	echo done!
}

link_cocos2d_libs

copy_xc4_project_templates

