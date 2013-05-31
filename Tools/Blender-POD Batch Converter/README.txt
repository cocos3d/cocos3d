#
# Created by Nikita Medvedev (@medvedNick) on 30.05.13
#

Assume that you have Blender files with 3d models and you want to convert all of them into .pod, so you can include them into your iOS game or app with Cocos3D.

The straightforward way is to manually export each file with Blender as dae, and then use the Collada2Pod instrument, as it is suggested in Cocos3D tutorials. The problem occurs when you have a lot of files to convert, since Blender is not able to export multiple files and Collada2Pod is not able to convert all of them simultaneously. Even with >20 files it becomes a very routine task.

The second and more flexible solution is to automate these processes, so the scripts within this pack were written. You can find them in "scripts" folder.

To launch these scripts you need Blender to be installed on your Mac, as well as Python and Perl interpreters.

The pack contains "scripts" folder, "Collada2POD" folder with utility for Mac, and 3 folders: "_blend", "_dae", "_pod", the first one with example file. These 3 folders are not necessary, they were created for convenience and to make example be able to run out-of-box.


SIMPLE USE:

You can use "main.sh" script with your Terminal to see if conversion goes right. If so, you will see "armchair.dae" with two textures in "_dae" folder, and "armchair.pod" in "_pod" folder. To import it into your Xcode project simply copy .pod file and all textures as usual.

The main.sh script assumes that your Blender executable is located in the standard directory "/Applications/blender.app/Contents/MacOS/blender". If not, edit the "main.sh" script to change the blender_path setting to the path to your Blender executable.

To do the same with multiple files, just copy .blend files into "_blend" folder and run "main.sh"


COMPLEX USE:

The first task - to export multiple files from Blender - is performed by "exporter.py" script in Python. The syntax is as follows:

<path_to_Blender> --background --python <path_to_exporter.py> -- <path_to_directory_with_blend_files> <path_to_output_directory> <include light flag: 0 or 1> <include camera flag: 0 or 1>

The script exports blend files from input directory as dae files into output directory. The search in input directory is not recursive, only files with ".blend" extension are handled. Export light flag is either 0 or 1, and it controls if script should export lights or not. The same thing with camera flag. The purpose for this is the common situation when there are lights and cameras in every scene, while we need to export only meshes. 

The second task is to convert multiple dae files from input directory into pod ones. This refers to "converter.pl" script in Perl.  The syntax is as follows:
perl converter.pl <path_to_Collada2POD> <path_to_input_directory> <path_to_output_directory>

For convenience the third script was made - "main.sh" in bash. It has no arguments and it launches "exporter.py" and then "converter.pl". If your Blender is not located in standard directory "/Applications/blender.app/Contents/MacOS/blender", you will need to specify it. Also, you can change all directories in "main.sh" to whatever you want.
