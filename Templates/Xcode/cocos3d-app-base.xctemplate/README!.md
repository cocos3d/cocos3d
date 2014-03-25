README!
----------------------

Cocos3D 2.0.0

Copyright (c) 2010-2014 The Brenwill Workshop Ltd. All rights reserved.
http://www.brenwill.com

+++++++++++++++++++++++++++++++++++


Getting Started
---------------

This starter application presents a 3D take on the ubiquitous "hello, world" application,
and can be compiled to run on any iOS devices.

The content of the scene is constructed in the initializeScene method in the
___PROJECTNAMEASIDENTIFIER___Scene.m file. To add your own 3D content, edit that method.

The ___PROJECTNAMEASIDENTIFIER___Scene.m file is also where you add interactive behaviour,
typically in the updateBeforeTransform: method.

You can also edit the applicationDidFinishLaunching: method in the
___PROJECTNAMEASIDENTIFIER___AppDelegate.m file to tweak the basic setup of your
Cocos3D application. This method is where the Cocos3D framework is hooked into the
Cocos2D framework, and Apple's OpenGL ES framework.

For a complete demonstration of almost all Cocos3D capabilities, see the fully-documented
CC3DemoMashUp demo app, which is your best tool for learning the capabilities of Cocos3D,
and how to work within the framework.

NOTE: The 'hello-world.pod' 3D model data file used for the 'hello, world' message model
is fairly large, because converting a font to a mesh results in a LOT of triangles.
When adapting this template project for your own application, don't forget to remove the
'hello-world.pod' from the Resources folder of your project!


Cocos2D & OpenGL ES Version Compatibility
-----------------------------------------

Cocos3D under iOS and Android is compatible with `Cocos2D` `3.x` and `Cocos2D` `2.1`, for 
using programmable-pipeline OpenGL ES 2.0, and is compatible with `Cocos2D` `1.1`, for using
fixed-pipeline OpenGL ES 1.1.

Cocos3D under OSX is compatible with `Cocos2D` `3.x` and `Cocos2D` `2.1`, for using 
programmable-pipeline OpenGL (OSX). Cocos3D is not compatible with `Cocos2D` `1.1` under OSX.

Choosing the appropriate Cocos3D template will automatically link to the corresponding version
of the `Cocos2D` library, if it exists in your template environment. You must ensure that you 
have downloaded the appropriate version of `Cocos2D`, and have installed its templates.


Creating POD 3D Model Files
---------------------------

Cocos3D reads 3D model content from POD files.

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
folder in the Cocos3D distribution. See the README.txt file in that folder for instructions.
The "Blender-POD Batch Converter" tool was created by Cocos3D user Nikita Medvedev.

