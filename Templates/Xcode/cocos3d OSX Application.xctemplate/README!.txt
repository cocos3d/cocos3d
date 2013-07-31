README!
----------------------

cocos3d 2.0.0

Copyright (c) 2010-2013 The Brenwill Workshop Ltd. All rights reserved.
http://www.brenwill.com

+++++++++++++++++++++++++++++++++++


Getting Started
---------------

This starter application presents a 3D take on the ubiquitous "hello, world" application,
and can be compiled to run on a Mac running OSX.

The content of the scene is constructed in the initializeScene method in the
___PROJECTNAMEASIDENTIFIER___Scene.m file. To add your own 3D content, edit that method.

The ___PROJECTNAMEASIDENTIFIER___Scene.m file is also where you add interactive behaviour,
typically in the updateBeforeTransform: method.

You can also edit the applicationDidFinishLaunching: method in the
___PROJECTNAMEASIDENTIFIER___AppDelegate.m file to tweak the basic setup of your
cocos3d application. This method is where the cocos3d framework is hooked into the
cocos2d framework, and Apple's OpenGL ES framework.

For a complete demonstration of almost all cocos3d capabilities, see the fully-documented
CC3DemoMashUp demo app, which is your best tool for learning the capabilities of cocos3d,
and how to work within the framework.

NOTE: The 'hello-world.pod' 3D model data file used for the 'hello, world' message model
is fairly large, because converting a font to a mesh results in a LOT of triangles.
When adapting this template project for your own application, don't forget to remove the
'hello-world.pod' from the Resources folder of your project!


cocos2d & OpenGL Version Compatibility
-----------------------------------------

cocos3d under OSX is compatible with `cocos2d` `2.1` and `2.0`, for using programmable-pipeline
OpenGL (OSX). cocos3d is not compatible with `cocos2d` `1.1` and `1.0.1` under OSX. By linking
to cocos2d 2.x, you will automatically use OpenGL with a programmable pipeline using GLSL shaders.

This template application will use whichever version of cocos2d you indicated when you ran
the install_cocos3d.sh script. You can easily change the version of cocos2d that is linked
to this project by following these steps within Xcode:

1. Delete the reference to the cocos2d group in the Xcode Project Navigator panel.
2. Run the install_cocos3d script and identify the new version of cocos2d to be linked.
3. Add the newly linked cocos2d files to the project by dragging the cocos2d folder from
   the cocos3d distribution folder to the Xcode Project Navigator panel.


Creating POD 3D Model Files
---------------------------

cocos3d reads 3D model content from POD files.

If you are using Blender, Maya, or 3DS Max as your 3D editor, you can install the PVRGeoPOD
plugin from Imagination Technologies to export directly from your editor to the POD file format.

For other editors, you can export your 3D model to a file in COLLADA 1.4 format, and then use
the standalone PVRGeoPOD app to convert the COLLADA file to the POD format.

Both the standalone and plugin versions of PVRGeoPOD are available free of charge from
Imagination Technologies, the supplier of the GPU's used in iOS devices.

Read the full instructions at http://brenwill.com/2011/cocos3d-importing-converting-collada-to-pod/
for more info on where to get the PVRGeoPOD converter, and how to use it to generate POD files.

If you are using Blender as your 3D editor, and have many .blend files to export to POD format,
you can use the command-line batch tool available in the "Tools/Blender-POD Batch Converter"
folder in the cocos3d distribution. See the README.txt file in that folder for instructions.
The "Blender-POD Batch Converter" tool was created by cocos3d user Nikita Medvedev.

